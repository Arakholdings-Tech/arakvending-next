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
      
      # Check if this handler is already registered using a shared resource
      lock_file = Rails.root.join('tmp', "event_handler_#{handler_key.gsub(/[^a-z0-9_-]/i, '_')}.lock")
      
      File.open(lock_file, File::RDWR | File::CREAT, 0644) do |f|
        if f.flock(File::LOCK_EX | File::LOCK_NB)
          # We got the lock, perform the subscription
          ActiveSupport::Notifications.subscribe(event) do |*args|
            handler.handle(args.last)
          end
          
          # Write to the file to indicate registration
          f.truncate(0)
          f.write("#{Process.pid} registered at #{Time.now}")
          f.flush
          
          # Keep the lock for the lifetime of the process
          at_exit { f.flock(File::LOCK_UN) }
          
          puts "Registered handler #{handler.name} for event #{event}"
        else
          puts "Handler #{handler.name} for event #{event} already registered in another process"
        end
      end
    end
  end
end
