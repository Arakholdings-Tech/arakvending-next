namespace :connect do
  task listen: :environment do
    begin
    vending_transport = Vending::Transport.new

    vending_transport.on_message 'MACHINE_STATUS' do |data, _length|
    end

    transport = Esocket::Transport.connect
    vending_transport.connect

    Esocket::Transport.send_message Esocket::Messages.initialize_terminal

    puts 'Press Ctrl+C to exit'
    sleep while true
  rescue 
    puts 'retrying....'
    sleep 4
    retry
  end
  rescue Interrupt
    puts "\nShutting down..."
    Esocket::Transport.send_message Esocket::Messages.close_terminal
    transport.stop
    sleep 4
  end
end
