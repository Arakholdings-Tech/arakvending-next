class CreateMachines < ActiveRecord::Migration[8.0]
  def change
    create_table :machines do |t|
      t.string :machine_id

      t.timestamps
    end
    add_index :machines, :machine_id, unique: true
  end
end
