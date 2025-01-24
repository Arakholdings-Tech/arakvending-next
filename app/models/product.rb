class Product < ApplicationRecord
  belongs_to :machine
  has_many :payments, dependent: :destroy

  after_save_commit :update_price
  after_save_commit :update_quantity

  def update_price
    return unless saved_change_to_price?

    normalized_price = (price * 100).to_i
    Vending::Transport.send_message Vending::Messages.set_slection_price(normalized_price, selection)
  end

  def update_quantity
    return unless saved_change_to_quantity?

    Vending::Transport.send_message Vending::Messages.set_selection_inventory(selection, quantity)
  end
end
