class Vending::AckController < MessageController
  def handle(transport, command, data)
    message = begin
      Vending::Transport.next_message('vending')
    rescue StandardError
      nil
    end
  if message.nil?
      
          transport.write_message Vending::Messages.ack
    else
      puts message.inspect
    transport.write_message message 
end
  end
end
