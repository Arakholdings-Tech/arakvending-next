class Consumer
  def handle(payload)
    raise NotImplementedError
  end

  def self.handle(payload)
    new.handle(payload)
  end
end
