class Transaction < ApplicationRecord
  belongs_to :payment

  enum :status,
       { queued: 'queued', pending: 'pending', processing: 'processing', completed: 'completed', failed: 'failed' }
end
