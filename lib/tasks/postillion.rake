require 'rails/commands/server/server_command'
namespace :postillion do
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
    transport = Esocket::Transport.connect

    Esocket::Transport.send_message Esocket::Messages.initialize_terminal

    puts 'Press Ctrl+C to exit'
    start_rails_server
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
