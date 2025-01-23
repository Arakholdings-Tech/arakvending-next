class Payment < ApplicationRecord
  belongs_to :product
  has_many :transactions

  enum :status, %i[queued pending processing completed]
end
