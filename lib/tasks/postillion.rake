namespace :postillion do
  def prepare_message(xml)
    # Convert to binary string
    xml_bytes = xml.encode('UTF-8').b

    # Create 4-byte length prefix (network byte order / big-endian)
    length_prefix = [xml_bytes.length].pack('N')

    # Combine length prefix and XML
    length_prefix + xml_bytes
  end

  def read_response(socket)
    # Read 4-byte length prefix
    length_bytes = socket.read(4)
    message_length = length_bytes.unpack1('N')

    # Read the message body
    socket.read(message_length)
  end

  task connect: :environment do
    builder = EsocketBuilder.build_interface do |xml|
      EsocketBuilder.initalize(xml, 'ARAK0001')
    end
    puts builder

    xml = builder

    # Convert XML to length-prefixed message
    message = prepare_message(xml)

    socket = TCPSocket.new('192.168.1.200', 23_001)
    # Send the message
    socket.write(message)

    # Read response
    response = read_response(response)

    puts response
  end
end
