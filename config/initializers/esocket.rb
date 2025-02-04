Rails.application.config.after_initialize do
  Esocket.configure do |config|
    config.terminal_id = ENV.fetch('ESOCKET_TERMINAL_ID', nil)
    config.host = ENV.fetch('ESOCKET_HOST', nil)
    config.port = ENV.fetch('ESOCKET_PORT', nil)
  end
end
