class EsocketBuilder
  NAMESPACE = 'http://www.mosaicsoftware.com/Postilion/eSocket.POS/'

  def self.build_interface
    builder = Nokogiri::XML::Builder.new do |xml|
      xml['Esp'].Interface(
        'Version' => '1.0',
        'xmlns:Esp' => NAMESPACE,
      ) do
        yield(xml) if block_given?
      end
    end
    builder.doc.to_xml
  end

  def self.initalize(xml, terminal_id)
    xml.Admin('TerminalId' => terminal_id, 'Action' => 'INIT') do
      xml.Register('Type' => 'CALLBACK', 'EventId' => 'DATA_REQUIRED')
      xml.Register('Type' => 'EVENT', 'EventId' => 'DEBUG_ALL')
    end
  end

  def self.close_terminal(xml, terminal_id)
    xml.Admin('TerminalId' => terminal_id, 'Action' => 'CLOSE') do
      xml.Register('Type' => 'CALLBACK', 'EventId' => 'DATA_REQUIRED')
      xml.Register('Type' => 'EVENT', 'EventId' => 'DEBUG_ALL')
    end
  end

  def self.transcation(xml, amount, terminal_id, transcation_id)
    xml.Transaction('TransactionAmount' => amount, 'TerminalId' => terminal_id, 'Type' => 'PURCHASE',
      'TransactionId' => transcation_id,) do
    end
  end

  def self.reversal(xml, transcation_id, terminal_id)
    xml.Transaction('TerminalId' => terminal_id, 'Type' => 'PURCHASE',
      'TransactionId' => transcation_id, 'Reversal' => 'TRUE',)
  end
end
