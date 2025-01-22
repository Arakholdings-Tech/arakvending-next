namespace :postillion do
  task connect: :environment do
    async_reader = AsyncTcpReader.new('192.168.10.158', 23_001)

    async_reader.connect

    puts 'Connected to server'

    async_reader.send_message Esocket::Messages.initialize_terminal('LINUX001')
    # sleep 2
    async_reader.send_message Esocket::Messages.transaction(100, 'LINUX001', rand(100_000..999_999))

    async_reader.start_reading do |message|
      puts Nokogiri::XML(message).to_xml
    end

    puts 'Press Ctrl+C to exit'
    sleep while true

    # Send the message
  end
end
