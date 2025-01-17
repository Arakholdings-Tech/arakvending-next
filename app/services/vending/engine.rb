class Vending::Engine
  COMMAND_QUEUE = []

  def enqueue(command)
    COMMAND_QUEUE << command
  end

  def command
    COMMAND_QUEUE.any ? COMMAND_QUEUE.shift : ack
  end

  def ack
    [0xfa, 0xfb, 0x42, 0x00, 0x43].pack('C*')
  end

  def calculate_bcc(data)
    data.bytes.reduce(0) { |sum, byte| sum ^ byte }
  end

  def select_buy(selection)
    data = [0xfa, 0xfb, 0x06, 0x05, Utils::HexGenerator.next, 0x00, 0x00, *selection]
    data << calculate_bcc(data.pack('C*'))

    data.pack('C*')
  end
end
