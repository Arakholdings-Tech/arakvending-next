class Transaction < ApplicationRecord
  belongs_to :payment

  monetize :amount_cents, as: 'amount'
  monetize :amount_approved_cents, as: 'amount_approved'

  enum :status,
    { queued: 'queued', pending: 'pending', processing: 'processing', completed: 'completed', failed: 'failed' }
end
