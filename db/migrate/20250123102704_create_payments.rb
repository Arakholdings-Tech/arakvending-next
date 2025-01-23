class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.belongs_to :product, null: false, foreign_key: true
      t.decimal :amount
      t.string :status
      t.timestamp :completed_at

      t.timestamps
    end
  end
end
