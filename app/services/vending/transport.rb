class Vending::Transport
  COMMAND_MAP = {
    poll: 'POLL',
    ack: 'ACK',
    machine_status: 'MACHINE_STATUS',
    request_sync_info: 'REQUEST_SYNC_INFO',
    select_buy: 'REQUEST_BUY',
    dispensing_status: 'DISPENSING_STATUS',
    report_selection: 'REPORT_SELECTION',
    select_selection: 'SELECT_SELECTION',
    recieve_money: 'RECIEVE_MONEY'
  }.freeze

  COMMANDS = {
    poll: 0x41,
    ack: 0x42,
    machine_status: 0x52,
    request_sync_info: 0x31,
    select_buy: 0x06,
    select_selection: 0x05,
    dispensing_status: 0x04,
    report_selection: 0x11,
    recieve_money: 0x27
  }.freeze

  MESSAGE_TYPES = COMMAND_MAP.values

  def initialize(port = '/dev/ttyUSB0')
    @message_handlers = {}
    @serial = UART.open port, 57_600
    @write_queue = Queue.new
  end

  def on_message(message, &block)
    @message_handlers[message] = block
  end

  def get_command(command)
    COMMAND_MAP[COMMANDS.key(command)]
  end

  def start
    on_message 'POLL' do |_data, _length|
      message = begin
        @write_queue.pop(true)
      rescue StandardError
        nil
      end
      @serial.write message || Vending::Messages.ack
    end
    raise 'Not connected' unless @serial

    Thread.new do
      loop do
        next unless @serial.wait_readable

        start = @serial.read(2).bytes
        start1, start2 = start

        unless start1 == 0xfa && start2 == 0xfb
          @serial.read
          next
        end

        begin
          command = @serial.read(1).unpack1('C')
          length = @serial.read(1).unpack1('C')
          data = @serial.read(length).unpack('C*')
          @serial.read(1)

          read_response(get_command(command), data, length)
        rescue IO::WaitReadable
          next
        rescue EOFError
          puts 'Connection closed by remote host'
          break
        end
      end
    end
  end

  def read_response(command, data, length)
    @serial.write Vending::Messages.ack

    MESSAGE_TYPES.each do |type|
      next unless type == command

      if @message_handlers[type]
        @message_handlers[type].call(data, length)
      else
        puts "Received #{type} message (no handler registered)"
        puts "Attributes: #{data.inspect}"
      end

      return type
    end
  end

  def send_message(data)
    @write_queue.push(data)
  end
end
