class CreateIoMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :io_messages do |t|
      t.binary :payload
      t.string :status
      t.string :queue

      t.timestamps
    end
    add_index :io_messages, :queue
  end
end
