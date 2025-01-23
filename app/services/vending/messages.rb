class Vending::Messages
  COMMANDS = {
    poll: 0x41,
    ack: 0x42,
    machine_status: 0x52,
    request_sync_info: 0x31,
    select_buy: 0x06,
    select_selection: 0x05,
    dispensing_status: 0x04,
    report_selection: 0x11,
    recieve_money: 0x27,
    cancel_selection: 0x05
  }.freeze

  class << self
    def ack
      data = [0xfa, 0xfb, 0x42, 0x00, 0x43]
      data.pack('C*')
    end

    def calculate_bcc(data)
      data.bytes.reduce(0) { |sum, byte| sum ^ byte }
    end

    def recieve_money(_amount)
      data = [
        0xfa,
        0xfb,
        COMMANDS[:recieve_money],
        0x06,
        HexGenerator.next,
        0x03,
        0, 20, 0, 0
      ]
      puts data.inspect
      data << calculate_bcc(data.pack('C*'))

      data.pack('C*')
    end

    def cancel_selection
      data = [
        0xfa,
        0xfb,
        COMMANDS[:cancel_selection],
        0x03,
        HexGenerator.next,
        0,
        0
      ]

      data << calculate_bcc(data.pack('C*'))

      data.pack('C*')
    end
  end
end
