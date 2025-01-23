class AddCommunicationNumberToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :seq_number, :string
  end
end
