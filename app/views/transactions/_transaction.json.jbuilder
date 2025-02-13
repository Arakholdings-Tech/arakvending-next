json.extract! transaction, :id, :transaction_id, :amount, :payment_id, :card_number, :amount_approved, :response_message, :rrn, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
