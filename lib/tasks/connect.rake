namespace :connect do
  task listen: :environment do
    UART.open '/dev/ttyUSB0', 57_600 do |serial|
      loop do
        next unless serial.wait_readable

        start = serial.read(2).bytes
        start1, start2 = start
        unless start1 == 0xfa && start2 == 0xfb
          serial.read
          next
        end

        command = serial.read(1).unpack1('C')
        length = serial.read(1).unpack1('C')

        engine = Vending::Engine.new

        case engine.get_command(command)

        when 'POLL'
          engine.verify(serial.read(1), [start1, start2, length, command])
          serial.write engine.command
          next
        when 'ACK'
          serial.read
          next
        when 'MACHINE_STATUS'
          serial.read(length)
          serial.read(1)
          respond_with_ack(serial)
          next
        when 'DISPENSING_STATUS'
          dispensing_status(serial)
          next
        when 'REPORT_SELECTION'
          packet_number = serial.read(1).unpack1('C*')
          selection_number = serial.read(2).bytes.pack('C*')
          bcc = serial.read(1).unpack1('C*')
          serial.read
          10.times { puts '================================================================' }
          puts 'Report selection:'
          puts "Packet number: #{packet_number}"
          puts "Selection number #{selection_number.inspect}"
          puts "bcc: #{bcc.inspect}"
          10.times { puts '================================================================' }
          respond_with_ack(serial)
          next
        when 'REQUEST_SYNC_INFO'
          serial.read
          puts 'Sync'
          respond_with_ack(serial)
          next
        when 'SELECT_SELECTION'
          communication_number, *selection_number = serial.read(length).unpack('C*')
          3.times { puts '===================================' }

          puts "Comm # #{communication_number}"
          puts "Selection # #{selection_number.join('')}"
          COMMAND_QUEUE << recieve_money
          serial.read(1)

          respond_with_ack(serial)
          next
        end
        puts 'Command'
        puts command.inspect
        puts command == 0x04
        puts length
        serial.read
      end
    end
  end
end
