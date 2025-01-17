class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.belongs_to :mechine, null: false, foreign_key: true
      t.string :name
      t.decimal :price
      t.integer :selection
      t.integer :quantity

      t.timestamps
    end
  end
end
