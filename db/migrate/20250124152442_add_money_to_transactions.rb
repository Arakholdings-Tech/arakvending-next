class AddMoneyToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_monetize :transactions, :amount
  end
end
