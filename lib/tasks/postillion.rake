namespace :postillion do
  task listen: :environment do
    begin
      vending_transport = Vending::Transport.new

      vending_transport.connect
      Vending::Transport.send_message Vending::Messages.request_sync_info

      puts 'Press Ctrl+C to exit'
      sleep while true
    rescue StandardError => e
      puts 'retrying....'
      puts e
      sleep 4
      retry
    end
  rescue Interrupt
    puts "\nShutting down..."
    sleep 4
  end
end
