namespace :connect do
  task listen: :environment do
    SEQ_NUMS = []
    vending_transport = Vending::Transport.new

    vending_transport.on_message 'MACHINE_STATUS' do |data, _length|
    end

    vending_transport.on_message 'SELECT_SELECTION' do |data, _length|
      seq_number, *selection_number = data
      next if SEQ_NUMS.include? seq_number

      SEQ_NUMS << seq_number
      selection = selection_number.join.to_i

      next if selection.zero?

      product = Product.find_by selection: selection
      puts product.inspect
      next if product.blank?

      payment = product.payments.create(amount: product.price, status: 'queued')

      Payments::Queued.trigger(payment)
    end

    transport = Esocket::Transport.connect
    vending_transport.connect

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
