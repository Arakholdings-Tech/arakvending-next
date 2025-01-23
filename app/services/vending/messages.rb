class Vending::Messages
  def self.ack
    data = [0xfa, 0xfb, 0x42, 0x00, 0x43]
    data.pack('C*')
  end
end
