class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments, id: :uuid do |t|
      t.text :info, null: false
      t.uuid :agent_id, null: false
      t.uuid :ticket_id, null: false

      t.timestamps
    end

    add_foreign_key :comments, :users, column: :agent_id
    add_foreign_key :comments, :tickets
    add_index :comments, :agent_id
    add_index :comments, :ticket_id
  end
end
