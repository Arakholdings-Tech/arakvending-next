class Payment < ApplicationRecord
  belongs_to :product
  has_many :transactions, dependent: :destroy

  monetize :amount_cents, as: 'amount'

  enum :status,
    { queued: 'queued', pending: 'pending', processing: 'processing', completed: 'completed',
      incomplete: 'incomplete', }

  def transaction
    transactions.last
  end
end
