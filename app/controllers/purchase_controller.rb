class PurchaseController < MessageController
  def process(_transport, _message_type, data)
    transaction = Transaction.find_by transaction_id: data[:TransactionId]

    return unless transaction.present?

    transaction.update(
      card_number: data[:CardNumber],
      rrn: data[:RetrievalRefNr],
      response_message: data[:ActionCode],
      cashback_amount_cents: 0,
      amount_approved_cents: data[:TransactionAmount],
    )
    return if ['completed', 'incomplete'].include? transaction.payment.status

    if data[:ActionCode] == 'APPROVE'
      transaction.completed!
      transaction.payment.completed!

      Vending::Transport.send_message Vending::Messages.recieve_money((transaction.amount * 100).to_i)

      ActionCable.server.broadcast('payment_channel', { transaction: transaction, success: true })
    else
      transaction.failed!
      transaction.payment.incomplete!

      Vending::Transport.send_message Vending::Messages.cancel_selection

      ActionCable.server.broadcast('payment_channel', { transaction: transaction, success: false })
    end
  end
end
