class EsocketBuilder
  NAMESPACE = 'http://www.mosaicsoftware.com/Postilion/eSocket.POS/'

  def self.build_interface
    builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml['Esp'].Interface(
        'Version' => '1.0',
        'xmlns:Esp' => NAMESPACE
      ) do
        yield(xml) if block_given?
      end
    end
    builder.doc.to_xml
  end

  def self.initalize(xml, terminal_id)
    xml.Admin('TerminalId' => terminal_id, 'Action' => 'INIT')
  end
end
