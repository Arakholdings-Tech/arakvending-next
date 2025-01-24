class Transport
  def self.send_message(message, queue)
    IoMessage.create(payload: message, queue: queue, status: :pending)
  end

  def self.next_message(queue)
    IoMessage.next_for(queue).payload
  end

  def connect
    raise NotImplementedError
  end

  def begin_write_loop
    raise NotImplementedError
  end

  def begin_read_loop
    raise NotImplementedError
  end
end
