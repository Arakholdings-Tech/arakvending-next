Rails.application.config.after_initialize do
  Esocket.configure do |config|
    config.terminal_id = 'ARAK0002'
    config.host = '192.168.29.80'
    config.port = 23_001
  end

  Dir[Rails.root.join('config', 'esocket_routes', '*.rb')].each { |file| require file }
end
