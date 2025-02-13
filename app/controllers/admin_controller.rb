class AdminController < MessageController
  def init(transport, message_type, _message)
    puts transport.inspect
    puts message_type.inspect
    puts message_type.inspect
    transaction_id = SecureRandom.random_number(100_000..999_999)
    Esocket::Transport.send_message Esocket::Messages.transaction(200, transaction_id)
  end

  def close(transport, message_type, _message)
    puts transport.inspect
    puts message_type.inspect
    puts message_type.inspect
  end
end
