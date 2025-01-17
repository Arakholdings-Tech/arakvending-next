class HexGenerator
  def initialize
    @last_number = nil
  end

  def next_hex
    loop do
      new_number = rand(1..255)
      unless new_number == @last_number
        @last_number = new_number
        return format("%02X", new_number).to_i(16)
      end
    end
  end

  def self.next
    instance ||= new

    instance.next_hex
  end
end
