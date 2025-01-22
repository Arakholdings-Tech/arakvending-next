class Esocket::Messages
  def self.initialize_terminal(terminal_id)
    EsocketBuilder.build_interface do |xml|
      EsocketBuilder.initalize(xml, terminal_id)
    end
  end
end
