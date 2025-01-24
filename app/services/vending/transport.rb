class Vending::Transport < Transport
  def initialize(port = '/dev/ttyUSB0')
    @message_handlers = {}
    @serial = UART.open port, 57_600
    @queue_wait = false
  end

  def connect
    start_read_loop
    start_write_loop
  end

  def start_read_loop
    Thread.new do
      loop do
        next unless @serial.wait_readable

        start1, start2 = @serial.read(2).bytes

        unless start1 == 0xfa && start2 == 0xfb
          @serial.read
          next
        end

        begin
          command = Vending::Messages.get_command @serial.read(1).unpack1('C')
          length = @serial.read(1).unpack1('C')
          data = @serial.read(length).unpack('C*')
          @serial.read(1)
          read_response(command, data)
        rescue IO::WaitReadable
          next
        end
      end
    end
  end

  def write_message(message)
    @serial.write message
  end

  def start_write_loop
    on_message 'POLL' do |_data, _length|
      message = begin
        Vending::Transport.next_message('vending')
      rescue StandardError
        nil
      end
      puts message.inspect
      @serial.write message || Vending::Messages.ack
    end
  end

  MESSAGE_TYPES = Vending::Messages::COMMANDS.keys.map { |t| t.to_s.upcase }

  def on_message(message, &)
    Vending::Transport.on_message(message, &)
  end

  def read_response(command, data)
    Vending::Router.dispatch(self, command, data)

    @serial.write Vending::Messages.ack
  end

  def send_message(data)
    Vending::Transport.send_message(data)
  end

  def self.send_message(data)
    super(data, 'vending')
  end

  def self.connect
    instance = new
    instance.connect
    instance
  end

  def self.message_handlers
    @message_handlers ||= {}
  end

  def self.on_message(type, &block)
    message_handlers[type] = block
  end

  def self.routes
    @routes ||= Vending::Router
  end
end
