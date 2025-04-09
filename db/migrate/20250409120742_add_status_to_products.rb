class AddStatusToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :operational, :boolean, null: false, default: true
  end
end
