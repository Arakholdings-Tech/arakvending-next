class RemoveAmountFromPayments < ActiveRecord::Migration[8.0]
  def change
    remove_column :payments, :amount, :decimal
  end
end
