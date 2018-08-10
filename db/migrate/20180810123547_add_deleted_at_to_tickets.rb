class AddDeletedAtToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :deleted_at, :datetime, default: nil
  end
end
