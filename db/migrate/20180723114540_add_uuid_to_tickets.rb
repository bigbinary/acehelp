class AddUuidToTickets < ActiveRecord::Migration[5.2]
  def up
    add_column :tickets, :uuid, :uuid, default: "gen_random_uuid()", null: false
    remove_column :tickets, :id
    rename_column :tickets, :uuid, :id
    execute "ALTER TABLE tickets ADD PRIMARY KEY (id);"
  end
end
