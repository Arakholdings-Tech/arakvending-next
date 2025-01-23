class Vending::Transport
  def initialize(_port = '/dev/ttyUSB0')
    @message_handlers = {}
  end

  def on_message(message, &block)
    @message_handlers[message] = block
  end
end
