namespace :connect do
  task listen: :environment do
    vending_transport = Vending::Transport.new

    vending_transport.on_message 'MACHINE_STATUS' do |data, _length, _transport|
    end
    SEQ_NUMS = []
    vending_transport.on_message 'SELECT_SELECTION' do |data, _length|
      seq_number, *selection_number = data
      next if SEQ_NUMS.include? seq_number

      SEQ_NUMS << seq_number
      selection = selection_number.join.to_i

      next if selection.zero?

      product = Product.find_by selection: selection
      puts product.inspect
      next unless product.present?

      payment = product.payments.create(amount: product.price, status: 'queued')

      Payments::Queued.trigger(payment)
    end

    vending_transport.start
    transport = Esocket::Transport.connect

    Esocket::Transport.send_message Esocket::Messages.initialize_terminal

    sleep while true

    puts 'Press Ctrl+C to exit'
    sleep while true
  rescue Interrupt
    puts "\nShutting down..."
    Esocket::Transport.send_message Esocket::Messages.close_terminal
    transport.stop
    sleep 4
  end
end
