class Esocket::Messages
  def self.initialize_terminal
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.initalize(xml, Esocket.config.terminal_id)
    end
  end

  def self.close_terminal
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.close_terminal(xml, Esocket.config.terminal_id)
    end
  end

  def self.transaction(amount, transaction_id)
    puts (amount * 100).to_i
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.transcation(xml, (amount * 100).to_i, Esocket.config.terminal_id, transaction_id)
    end
  end

  def self.reversal(amount)
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.reversal(xml, amount, Esocket.config.terminal_id)
    end
  end
end
