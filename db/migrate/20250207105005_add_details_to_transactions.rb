class AddDetailsToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :card_number, :string
    add_column :transactions, :rrn, :string
    add_column :transactions, :method, :string
    add_column :transactions, :response_message, :string
    add_monetize :transactions, :cashback_amount
    add_monetize :transactions, :amount_approved
  end
end
