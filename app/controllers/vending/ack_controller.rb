class Vending::AckController < MessageController
  def handle(transport, command, data)
    message = begin
      Vending::Transport.next_message('vending')
    rescue StandardError
      nil
    end
    puts message.inspect
    transport.write_message message || Vending::Messages.ack
  end
end
