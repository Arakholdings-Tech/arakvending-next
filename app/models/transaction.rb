class Transaction < ApplicationRecord
  belongs_to :payment

  monetize :amount_cents, as: 'amount'

  enum :status,
    { queued: 'queued', pending: 'pending', processing: 'processing', completed: 'completed', failed: 'failed' }
end
