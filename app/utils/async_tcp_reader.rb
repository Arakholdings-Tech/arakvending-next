class AsyncTcpReader
  SMALL_MESSAGE_MAX = 65_535 # 2^16 - 1
  TWO_BYTE_HEADER_SIZE = 2
  SIX_BYTE_HEADER_SIZE = 6
  EXTENDED_HEADER_MARKER = "\xFF\xFF".b

  def initialize(host, port)
    @host = host
    @port = port
    @socket = nil
    @buffer = ''.b # Binary string buffer
    @running = false
  end

  def connect
    @socket = TCPSocket.new(@host, @port)
    @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
    @running = true
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
          puts 'Connection closed by remote host'
          break
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
      yield message if block_given?
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

  def handle_message(message)
    # Override this method to handle complete messages
    puts "Received message of length #{message.bytesize}: #{message}"
  end

  public

  def write(data)
    length = data.bytesize
    header = create_header(length)
    @socket.write(header + data)
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
    @socket&.close
  end
end
