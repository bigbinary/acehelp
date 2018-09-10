class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings, id: :uuid do |t|
      t.string :base_url, null: false
      t.string :app_url, null: false
      t.boolean :visibility, null: false, default: false
      t.references(:organization, index: true)
      t.timestamps
    end
  end
end
