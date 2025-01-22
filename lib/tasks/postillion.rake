namespace :postillion do
  task connect: :environment do
    async_reader = AsyncTcpReader.new('192.168.10.158', 23_001)

    async_reader.connect

    puts 'Connected to server'

    async_reader.write Esocket::Messages.initialize_terminal('LINUX001')

    async_reader.start_reading do |message|
      p message
    end

    puts 'Press Ctrl+C to exit'
    sleep while true

    # Send the message
  end
end
