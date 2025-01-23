class Payment < ApplicationRecord
  belongs_to :product
  has_many :transactions

  enum :status,
       { queued: 'queued', pending: 'pending', processing: 'processing', completed: 'completed',
         incomplete: 'incomplete' }
end
