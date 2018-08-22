class CreateNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :notes, id: :uuid do |t|
      t.text :details, null: false
      t.uuid :agent_id, null: false
      t.uuid :ticket_id, null: false

      t.timestamps
    end

    add_foreign_key :notes, :users, column: :agent_id
    add_foreign_key :notes, :tickets
    add_index :notes, :agent_id
    add_index :notes, :ticket_id
  end
end
