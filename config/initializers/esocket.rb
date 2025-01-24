Rails.application.config.after_initialize do
  Esocket.configure do |config|
    config.terminal_id = 'ARAK0002'
    config.host = 'fd79:56b9:958d:10::433'
    config.port = 23_001
  end

  Dir[Rails.root.join('config', 'esocket_routes', '*.rb')].each { |file| require file }
end
