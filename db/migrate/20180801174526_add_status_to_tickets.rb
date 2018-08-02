class AddStatusToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :status, :string, null: false, default: 'open'
  end
end
