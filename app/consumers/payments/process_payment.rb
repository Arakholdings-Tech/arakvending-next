class Payments::ProcessPayment < Consumer
  def handle(payload)
    payment = payload[:payment]

    payment.pending!

    puts payment.inspect

    transaction = payment.transactions.create(
      amount: payment.amount,
      transaction_id: SecureRandom.random_number(100_000..999_999),
      status: :pending
    )

    Esocket::Transport.send_message(Esocket::Messages.transaction(transaction.amount, transaction.transaction_id))
  end
end
