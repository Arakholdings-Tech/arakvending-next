class AdminController < MessageController
  def init(transport, message_type, _message)
    puts transport.inspect
    puts message_type.inspect
    puts message_type.inspect
  end

  def close(transport, message_type, _message)
    puts transport.inspect
    puts message_type.inspect
    puts message_type.inspect
  end
end
