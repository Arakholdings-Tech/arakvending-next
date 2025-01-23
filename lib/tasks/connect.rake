namespace :connect do
  task listen: :environment do
    vending_transport = Vending::Transport.new

    vending_transport.on_message 'MACHINE_STATUS' do |data, _length, _transport|
    end

    vending_transport.on_message 'SELECT_SELECTION' do |data, _length|
      _, *selection_number = data
      selection = selection_number.join.to_i

      next if selection.zero?

      product = Product.find_by selection: selection
      next unless product.present?

      payment = product.payments.create(amount: product.price, status: 'queued')

      Payments::Queued.trigger(payment)
    end

    vending_transport.start
    Esocket::Transport.connect

    Esocket::Transport.send_message Esocket::Messages.initialize_terminal

    sleep while true
  end
end
