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
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.transcation(xml, amount, Esocket.config.terminal_id, transaction_id)
    end
  end

  def self.reversal(transaction_id)
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.reversal(xml, transaction_id, Esocket.config.terminal_id)
    end
  end

  def self.callback(event_id, event_data)
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.callback(xml, event_id, Esocket.config.terminal_id, event_data)
    end
  end

  def self.cancel_transaction(transaction_id)
    callback('CANCEL_TRAN', transaction_id)
  end
end
