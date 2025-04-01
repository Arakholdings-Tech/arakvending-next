class Product < ApplicationRecord
  belongs_to :machine
  has_many :payments, dependent: :destroy
  has_one_attached :picture

  monetize :price_cents, as: 'price'

  after_save_commit :update_price
  after_save_commit :update_quantity

  def update_price
    return unless saved_change_to_price_cents?

    Vending::Transport.send_message Vending::Messages.set_slection_price(price_cents, selection)
  end

  def update_quantity
    return unless saved_change_to_quantity?

    Vending::Transport.send_message Vending::Messages.set_selection_inventory(selection, quantity)
  end
end
