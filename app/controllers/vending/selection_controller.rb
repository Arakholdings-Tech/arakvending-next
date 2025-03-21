class Vending::SelectionController < MessageController
  SEQ_NUMS = []

  def selected(transport, command, data)
    seq_number, *selection_number = data
    return if SEQ_NUMS.include? seq_number

    SEQ_NUMS << seq_number
    selection = selection_number.join.to_i

    return if selection.zero?

    product = Product.find_by selection: selection
    nil if product.blank?

    payment = product.payments.create(amount: product.price, status: 'queued')

    # Vending::Transport.send_message Vending::Messages.recieve_money(100.to_i)
    Payments::Queued.trigger(payment)
  end

  def inventory(transport, command, data)
    _, _, selection, quantity = data

    Product.find_by(selection: selection).update(quantity: quantity)
  end

  def price(transport, command, data)
    _, _, selection, *price = data
    product = Product.find_by(selection: selection)
    price = price.pack('C*').unpack1('N')
    product.update(price_cents: price)
  end

  def dispensing(_transport, _command, data)
    _, status, *selection_number = data
    selection_number = selection_number.join.to_i
    return if status == 0x01

    product = Product.find_by(selection: selection_number)
    puts status

    case status
    when 0x02
      product.decrement!(:quantity)
    when 0x03
      Rails.logger.error("Jamm on product #{selection_number}")
      Rails.logger.info("Issuing a refund at #{Time.current}")
      puts 'jamm'

      Esocket::Transport.send_message(Esocket::Messages.reversal(
        product.payments.last.transactions.last.transaction_id,
      ))
    when 0x04
      Rails.logger.error("Motor doesn't stop on product #{selection_number}")
      puts 'motor didnt stop'

      Rails.logger.info("Issuing a refund at #{Time.current}")
      Esocket::Transport.send_message(Esocket::Messages.reversal(
        product.payments.last.transactions.last.transaction_id,
      ))
    when 0x06
      Rails.logger.error("Motor doesn't exist on product #{selection_number}")

      Rails.logger.info("Issuing a refund at #{Time.current}")
      puts 'motor not exisit'

      Esocket::Transport.send_message(Esocket::Messages.reversal(
        product.payments.last.transactions.last.transaction_id,
      ))
    when 0x07
      Rails.logger.error("Elevator error on product #{selection_number}")
      Rails.logger.info("Issuing a refund at #{Time.current}")
      puts 'elevator error'

      Esocket::Transport.send_message(Esocket::Messages.reversal(
        product.payments.last.transactions.last.transaction_id,
      ))
    end
  end
end
