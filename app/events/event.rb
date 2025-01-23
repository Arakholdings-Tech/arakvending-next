class Event
  def event_type
    self.class.name.underscore
  end

  def self.event_type
    name.underscore
  end

  def payload
    {
      event_type: event_type,
      timestamp: Time.current
    }
  end

  def self.trigger(*)
    new(*).trigger
  end

  def trigger
    ActiveSupport::Notifications.instrument event_type, payload
  end
end
