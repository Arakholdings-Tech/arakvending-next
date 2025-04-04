class Vending::Messages
  COMMANDS = {
    poll: 0x41,
    ack: 0x42,
    machine_status: 0x52,
    request_sync_info: 0x31,
    select_buy: 0x03,
    select_selection: 0x05,
    dispensing_status: 0x04,
    report_selection: 0x11,
    recieve_money: 0x27,
    cancel_selection: 0x05,
    set_selection_price: 0x12,
    set_selection_inventory: 0x13,
    set_selection_capacity: 0x14
  }.freeze

  class << self
    def ack
      data = [ 0xfa, 0xfb, 0x42, 0x00, 0x43 ]
      data.pack("C*")
    end

    def calculate_bcc(data)
      data.bytes.reduce(0) { |sum, byte| sum ^ byte }
    end

    def request_sync_info
      data = [ 0xfa, 0xfb, COMMANDS[:request_sync_info], 1, HexGenerator.next ]
      data << calculate_bcc(data.pack("C*"))
      data.pack("C*")
    end

    def recieve_money(amount)
      amount_payload = amount.to_s.split("")
      cents = amount_payload.last(2)
      dollars = amount_payload.slice(0, amount_payload.length - 2)
      amount_formatted = [ dollars.join, *cents ].map(&:to_i)

      data = [ 0xfa, 0xfb, COMMANDS[:recieve_money], 0x06, HexGenerator.next, 0x03, 0, 20,0,0 ]
      data << calculate_bcc(data.pack("C*"))
      data.pack("C*")
    end

    def select_buy(selection)
      data = [ 0xfa, 0xfb, 0x03, 3, HexGenerator.next, 0, selection ]
      data << calculate_bcc(data.pack("C*"))
      data.pack("C*")
    end

    def cancel_selection
      data = [ 0xfa, 0xfb, COMMANDS[:cancel_selection], 0x03, HexGenerator.next, 0, 0 ]
      data << calculate_bcc(data.pack("C*"))
      data.pack("C*")
    end

    def format_money(amount)
      amount.to_s.chars.map(&:to_i).unshift(0)
    end

    def get_command(command)
      COMMANDS.key(command).to_s.upcase
    end

    def set_slection_price(price, selection)
      data = [
        0xfa,
        0xfb,
        COMMANDS[:set_selection_price],
        0x07,
        HexGenerator.next,
        0,
        selection,
        *[ price ].pack("N").unpack("C*")
      ]
      data << calculate_bcc(data.pack("C*"))
      data.pack("C*")
    end

    def set_selection_inventory(selection, inventory)
      data = [
        0xfa,
        0xfb,
        COMMANDS[:set_selection_inventory],
        0x04,
        HexGenerator.next,
        0,
        selection,
        inventory
      ]
      data << calculate_bcc(data.pack("C*"))
      data.pack("C*")
    end

    def set_selection_capacity(selection, capacity)
      data = [
        0xfa,
        0xfb,
        COMMANDS[:set_selection_capacity],
        0x04,
        HexGenerator.next,
        0,
        selection,
        capacity
      ]
      data << calculate_bcc(data.pack("C*"))
      data.pack("C*")
    end
  end
end
