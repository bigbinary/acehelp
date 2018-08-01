class AddAgentIdToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :agent_id, :uuid
    add_foreign_key :tickets, :users, column: :agent_id
  end
end
