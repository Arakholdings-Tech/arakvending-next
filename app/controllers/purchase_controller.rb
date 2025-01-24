class PurchaseController < MessageController
  def process(_transport, _message_type, data)
    puts data.inspect
    transaction = Transaction.find_by transaction_id: data[:TransactionId]

    return unless transaction.present?

    return if %w[completed incomplete].include? transaction.payment.status

    if data[:ActionCode] == 'APPROVE'
      transaction.completed!
      transaction.payment.completed!

      Vending::Transport.send_message Vending::Messages.recieve_money((transaction.amount * 100).to_i)
    else
      transaction.failed!
      transaction.payment.incomplete!

      Vending::Transport.send_message Vending::Messages.cancel_selection
    end
  end
end
