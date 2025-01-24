namespace :connect do
  task listen: :environment do
    SEQ_NUMS = []
    vending_transport = Vending::Transport.new

    vending_transport.on_message 'MACHINE_STATUS' do |data, _length|
    end

    transport = Esocket::Transport.connect
    vending_transport.connect

    Esocket::Transport.send_message Esocket::Messages.initialize_terminal

    sleep while true

    puts 'Press Ctrl+C to exit'
    sleep while true
  rescue Interrupt
    puts "\nShutting down..."
    Esocket::Transport.send_message Esocket::Messages.close_terminal
    transport.stop
    sleep 4
  end
end
