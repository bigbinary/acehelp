class CreateTriggers < ActiveRecord::Migration[5.2]
  def change
    create_table :triggers, id: :uuid do |t|
      t.string :slug, null: false
      t.text :description
      t.boolean :active, default: true
      t.json :configuration

      t.timestamps
    end
    Trigger.create(slug: 'auto_close_resoved_tickets', description: "Auto close 'Resolved' tickets in 4 days")
    Trigger.create(slug: 'auto_assign_ticket_to_agent', description: "Auto assign ticket to the agent who responded to the ticket")
    Trigger.create(slug: 'auto_change_status_for_customer_reply', description: "If customer replies then automatically change status to 'open' for any ticket")
  end

end
