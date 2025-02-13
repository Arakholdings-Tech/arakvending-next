require 'rails/commands/server/server_command'
namespace :connect do
  def start_rails_server(options = {})
    default_options = {
      Port: 3000,
      Host: '0.0.0.0',
      Environment: 'development',
      daemonize: false,
      config: 'config.ru',
      log_stdout: true,
      early_hints: true,
    }

    # Merge provided options with defaults
    server_options = default_options.merge(options)

    # Create a new Rails server instance
    server = Rails::Server.new(server_options)

    # Start the server
    begin
      puts 'Starting Rails server with options:'
      server_options.each { |key, value| puts "  #{key}: #{value}" }
      server.start
    rescue StandardError => e
      puts "Failed to start Rails server: #{e.message}"
      puts e.backtrace
    end
  end
  task listen: :environment do
    vending_transport = Vending::Transport.new

    vending_transport.on_message 'MACHINE_STATUS' do |data, _length|
    end

    transport = Esocket::Transport.connect
    vending_transport.connect

    Esocket::Transport.send_message Esocket::Messages.initialize_terminal

    sleep while true

    puts 'Press Ctrl+C to exit'
    sleep while true
  rescue StandardError
    puts 'retrying....'
    sleep 4
    retry
  rescue Interrupt
    puts "\nShutting down..."
    Esocket::Transport.send_message Esocket::Messages.close_terminal
    transport.stop
    sleep 4
  end
end
