class Esocket::Transport
  SMALL_MESSAGE_MAX = 65_535 # 2^16 - 1
  TWO_BYTE_HEADER_SIZE = 2
  SIX_BYTE_HEADER_SIZE = 6
  EXTENDED_HEADER_MARKER = "\xFF\xFF".b
  WRITE_TIMEOUT = 1 # Timeout in seconds for write operations
  MESSAGE_TYPES = %w[Transaction Event Callback Inquiry Admin].freeze

  def self.write_queue
    @write_queue ||= Queue.new
  end

  def self.message_handlers
    @message_handlers ||= {}
  end

  def initialize(host, port)
    @host = host
    @port = port
    @socket = nil
    @buffer = ''.b # Binary string buffer
    @running = false
    @write_thread = nil
    @message_handlers = {}
  end

  def self.connect
    instance = new(Esocket.config.host, Esocket.config.port)
    instance.connect
    instance
  end

  def connect
    @socket = TCPSocket.new(@host, @port)
    @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
    @running = true
    start_write_thread
    start_reading
  end

  def reconnect
    @socket = TCPSocket.new(@host, @port)
    @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
  end

  def on_message(type, &block)
    Esocket::Transport.on_message(type, &block)
  end

  def self.on_message(type, &block)
    message_handlers[type] = block
  end

  def self.routes
    @routes ||= Esocket::Router
  end

  def parse_xml_message(xml_string)
    doc = Nokogiri::XML(xml_string) do |config|
      config.strict.noblanks
    end

    doc.remove_namespaces! # Remove namespace for easier parsing

    # Look for any of our message types in the document
    MESSAGE_TYPES.each do |type|
      element = doc.at_css(type)
      next unless element

      attributes = Hash.from_xml(element.to_xml)[type].with_indifferent_access

      if attributes['Action'].present?
        Esocket::Router.dispatch(self, attributes['Action'], attributes, type)
      elsif attributes['EventId'].present?
        Esocket::Router.dispatch(self, attributes['EventId'], attributes, type)
      elsif attributes['Type'].present?
        Esocket::Router.dispatch(self, attributes['Type'], attributes, type)
      else
        Esocket::Router.dispatch(self, type, attributes)
      end
    end
  rescue Nokogiri::XML::SyntaxError => e
    puts "XML parsing error: #{e.message}"
  end

  def start_write_thread
    @write_thread = Thread.new do
      while @running

        begin
          # Dequeue message with timeout to allow checking @running
          message = begin
            Esocket::Transport.write_queue.pop(true)
          rescue StandardError
            nil
          end
          if message
            write_message_with_retry(message)
          else
            # No message available, sleep briefly
            sleep 0.1
          end
        rescue IOError, Errno::EPIPE => e
          puts "Write error: #{e.message}"
          break
        end
      end
    end
  end

  def write_message_with_retry(message)
    retries = 1
    length = message.bytesize
    header = create_header(length)
    frame = header + message

    begin
      raise "Socket not writable after #{WRITE_TIMEOUT} seconds" unless @socket.wait_writable(WRITE_TIMEOUT)

      bytes_written = 0
      while bytes_written < frame.bytesize
        return unless @running # Check if we should stop

        # Only write what's remaining
        remaining = frame.byteslice(bytes_written..-1)

        # Check writability before each write attempt
        raise "Socket not writable after #{WRITE_TIMEOUT} seconds" unless @socket.wait_writable(WRITE_TIMEOUT)

        # Write and track progress
        bytes_written += @socket.write_nonblock(remaining)
      end

      @socket.flush if bytes_written > 0
    rescue IO::WaitWritable
      # Socket temporarily unavailable, retry if attempts remain
      retries -= 1
      if retries > 0
        sleep 0.1
        retry
      else
        puts 'Failed to write message after 3 attempts'
      end
    rescue StandardError => e
      puts "Write error: #{e.message}"
    end
  end

  def start_reading(&block)
    raise 'Not connected' unless @socket

    Thread.new do
      while @running
        next unless @socket.wait_readable(0.1)

        begin
          chunk = @socket.read_nonblock(1024)
          @buffer += chunk
          process_buffer(&block)
        rescue IO::WaitReadable
          next
        rescue EOFError
          puts 'Connection closed by remote host, reconnecting..'
          reconnect
        end
      end
    end
  end

  private

  def process_buffer
    until @buffer.empty?
      # Try to read the header first
      header_size = peek_header_size
      return if @buffer.size < header_size # Need more data

      message_length = get_message_length(header_size)
      total_length = header_size + message_length

      # Check if we have the complete message
      return if @buffer.size < total_length

      # Extract the message and remove it from buffer
      message = @buffer[header_size, message_length]
      @buffer = @buffer[total_length..-1]

      # Process the complete message
      parse_xml_message(message)
    end
  end

  def peek_header_size
    return TWO_BYTE_HEADER_SIZE if @buffer.size < TWO_BYTE_HEADER_SIZE

    if @buffer[0, 2] == EXTENDED_HEADER_MARKER
      SIX_BYTE_HEADER_SIZE
    else
      TWO_BYTE_HEADER_SIZE
    end
  end

  def get_message_length(header_size)
    if header_size == TWO_BYTE_HEADER_SIZE
      # First byte * 256 + second byte
      (@buffer[0].ord * 256) + @buffer[1].ord
    else
      # Skip FF FF marker and read 4-byte length
      @buffer[2, 4].unpack1('N') # Network byte order (big-endian)
    end
  end

  public

  def write(data)
    length = data.bytesize
    header = create_header(length)
    @socket.write(header + data)
  end

  def send_message(data)
    Esocket::Transport.send_message(data)
  end

  def self.send_message(data)
    write_queue.push(data)
  end

  def message_queue_size
    Esocket::Transport.write_queue.size
  end

  def create_header(length)
    if length < SMALL_MESSAGE_MAX
      # Two-byte header
      [length / 256, length % 256].pack('C2')
    else
      # Six-byte header: FF FF followed by 4-byte length
      EXTENDED_HEADER_MARKER + [length].pack('N')
    end
  end

  def stop
    @running = false
    # Clear and close the write queue
    Esocket::Transport.write_queue.clear
    @write_thread&.join(2) # Wait up to 2 seconds for write thread to finish

    @socket&.close
  end

  def close
    stop
  end
end
