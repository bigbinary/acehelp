class AddNoteToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :note, :text
  end
end
