class Payments::ProcessPayment < Consumer
  def handle(payload)
    payment = payload[:payment]
    return unless payment.queued?
    payment.with_lock do

    payment.pending!

    transaction = payment.transactions.create(
      amount: payment.amount,
      transaction_id: SecureRandom.random_number(100_000..999_999),
      status: 'pending',
    )

    Esocket::Transport.send_message(Esocket::Messages.transaction(transaction.amount_cents, transaction.transaction_id))
    end
  end
end
