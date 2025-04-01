class Machine < ApplicationRecord
  has_many :products, dependent: :destroy
end
