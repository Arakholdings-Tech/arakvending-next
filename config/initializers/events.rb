Rails.application.config.after_initialize do
  Events::Dispatcher.register
end
