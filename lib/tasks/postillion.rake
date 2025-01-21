namespace :postillion do
  def prepare_message(xml)
    # Convert to binary string
    xml_bytes = xml.encode('UTF-8').b

    # Create 4-byte length prefix (network byte order / big-endian)
    length = [xml_bytes.length].pack('N')

    # Combine length prefix and XML
    length + xml_bytes
  end

  def read_response(socket)
    # Read 4-byte length prefix
    length_bytes = socket.read(400_000)
    message_length = length_bytes
    puts message_length

    # Read the message body
    # message = socket.read(message_length)
    # puts message
  end

  def read_data_loop(socket)
    while true
      while IO.select([socket], nil, nil, 2) && (line = socket.recv(50))
        p line
      end
    end
  end

  task connect: :environment do
    builder = EsocketBuilder.build_interface do |xml|
      EsocketBuilder.initalize(xml, 'ARAK0002')
    end

    xml = builder

    # Convert XML to length-prefixed message
    message = prepare_message(xml)

    socket = TCPSocket.new('192.168.1.200', 23_001)

    puts socket.inspect
    # Send the message
    socket.write(message)

    # Read response
    response = read_response(socket)

    puts response
  end
end
