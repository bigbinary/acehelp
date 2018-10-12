class AddPriorityToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :priority, :string, null: false, default: 'medium'
  end
end
