class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings, id: :uuid do |t|
      t.string :base_url
      t.boolean :visibility, null: false, default: false
      t.uuid :organization_id, null: false
      t.timestamps
    end
    add_foreign_key :settings, :organizations
    add_index :settings, :organization_id
  end
end
