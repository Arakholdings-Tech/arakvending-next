class Vending::SelectionController < MessageController
  SEQ_NUMS = []

  def selected(transport, command, data)
    seq_number, *selection_number = data
    return if SEQ_NUMS.include? seq_number

    SEQ_NUMS << seq_number
    selection = selection_number.join.to_i

    return if selection.zero?

    product = Product.find_by selection: selection
    return if product.blank?

    payment = product.payments.create(amount: product.price, status: 'queued')

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
end
