class Product < ApplicationRecord
  belongs_to :machine
  has_many :payments
end
