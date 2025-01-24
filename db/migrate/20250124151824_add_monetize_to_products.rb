class AddMonetizeToProducts < ActiveRecord::Migration[8.0]
  def change
    add_monetize :products, :price
  end
end
