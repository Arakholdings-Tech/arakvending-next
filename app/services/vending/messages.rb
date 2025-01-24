class Vending::Messages
  COMMAND_MAP = {
    poll: 'POLL',
    ack: 'ACK',
    machine_status: 'MACHINE_STATUS',
    request_sync_info: 'REQUEST_SYNC_INFO',
    select_buy: 'REQUEST_BUY',
    dispensing_status: 'DISPENSING_STATUS',
    report_selection: 'REPORT_SELECTION',
    select_selection: 'SELECT_SELECTION',
    recieve_money: 'RECIEVE_MONEY',
  }.freeze

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
    cancel_selection: 0x05,
  }.freeze

  class << self
    def ack
      data = [0xfa, 0xfb, 0x42, 0x00, 0x43]
      data.pack('C*')
    end

    def calculate_bcc(data)
      data.bytes.reduce(0) { |sum, byte| sum ^ byte }
    end

    def recieve_money(amount)
      data = [0xfa, 0xfb, COMMANDS[:recieve_money], 0x06, HexGenerator.next, 0x03, 0, 20, 0, 0]
      data << calculate_bcc(data.pack('C*'))
      data.pack('C*')
    end

    def cancel_selection
      data = [0xfa, 0xfb, COMMANDS[:cancel_selection], 0x03, HexGenerator.next, 0, 0]
      data << calculate_bcc(data.pack('C*'))
      data.pack('C*')
    end

    def format_money(amount)
      amount.to_s.chars.map(&:to_i).unshift(0)
    end

    def get_command(command)
      COMMAND_MAP[COMMANDS.key(command)]
    end
  end
end
