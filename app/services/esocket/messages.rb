class Esocket::Messages
  def self.initialize_terminal(terminal_id)
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.initalize(xml, terminal_id)
    end
  end

  def self.close_terminal(terminal_id)
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.close_terminal(xml, terminal_id)
    end
  end

  def self.transaction(amount, terminal_id, transaction_id)
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.transcation(xml, amount, terminal_id, transaction_id)
    end
  end

  def self.reversal(amount, terminal_id)
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.reversal(xml, amount, terminal_id)
    end
  end
end
