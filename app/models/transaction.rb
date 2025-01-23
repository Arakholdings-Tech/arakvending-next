class Transaction < ApplicationRecord
  belongs_to :payment

  enum :status, %i[queued pending processing completed]
end
