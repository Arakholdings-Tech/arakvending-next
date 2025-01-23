class Events::Dispatcher
  EVENTS = {
    Payments::Queued.event_type => [Payments::ProcessPayment]
  }.freeze

  class << self
    def register
      EVENTS.each do |event, handlers|
        handlers.each do |handler|
          register_handler(event, handler)
        end
      end
    end

    private

    def registered_handlers
      @registered_handlers ||= Set.new
    end

    def register_handler(event, handler)
      handler_key = "#{event}:#{handler.name}"
      return if registered_handlers.include?(handler_key)

      ActiveSupport::Notifications.subscribe(event) do |*args|
        handler.handle(args.last)
      end

      registered_handlers.add(handler_key)
    end
  end
end
