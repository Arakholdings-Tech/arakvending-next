namespace :postillion do
  MESSAGE_TYPES = %w[Transaction Event Callback Inquiry]
  MESSAGE_HANDLERS = {}

  def on_message(type, &block)
    MESSAGE_HANDLERS[type] = block
  end

  task connect: :environment do
    async_reader = AsyncTcpReader.new('192.168.10.158', 23_001)

    async_reader.connect

    puts 'Connected to server'

    async_reader.send_message Esocket::Messages.initialize_terminal('LINUX001')
    # sleep 2

    async_reader.start_reading

    async_reader.on_message 'Transaction' do |type, attributes, _element|
      puts type
      puts attributes
    end

    async_reader.on_message 'Admin' do |_type, attributes, _element|
      puts attributes
      case attributes['Action']
      when 'INIT'
        if attributes['ActionCode'] == 'APPROVE'
          async_reader.send_message Esocket::Messages.transaction(1000, 'LINUX001', rand(100_000..999_999))
        else
          Rails.logger.error 'Failed to initialize terminal'
          async_reader.close
        end
      when 'CLOSE'
        async_reader.close
        exit
      end
    end

    puts 'Press Ctrl+C to exit'
    sleep while true
  rescue Interrupt
    puts "\nShutting down..."
    async_reader.send_message Esocket::Messages.close_terminal('LINUX001')
    sleep 2
  end
end
