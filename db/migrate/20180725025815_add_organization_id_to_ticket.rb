class AddOrganizationIdToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :organization_id, :uuid
    add_foreign_key :tickets, :organizations
    add_index :tickets, :organization_id

    change_column :tickets, :email, :string, null: false
    change_column :tickets, :message, :text, null: false
  end
end
