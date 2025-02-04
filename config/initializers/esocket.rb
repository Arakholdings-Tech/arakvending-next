Rails.application.config.after_initialize do
  Esocket.configure do |config|
    config.terminal_id = 'ARAK0002'
    config.host = '127.0.0.1'
    config.port = 23_001
  end
end
