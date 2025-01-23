class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.string :transaction_id
      t.string :status
      t.decimal :amount
      t.belongs_to :payment, null: false, foreign_key: true

      t.timestamps
    end
    add_index :transactions, :transaction_id, unique: true
  end
end
