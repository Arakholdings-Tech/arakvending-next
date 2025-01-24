class RemoveAmountFromTransactions < ActiveRecord::Migration[8.0]
  def change
    remove_column :transactions, :amount, :decimal
  end
end
