class AddMoneyToPayment < ActiveRecord::Migration[8.0]
  def change
    add_monetize :payments, :amount
  end
end
