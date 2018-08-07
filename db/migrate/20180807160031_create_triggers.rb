class CreateTriggers < ActiveRecord::Migration[5.2]
  def change
    create_table :triggers, id: :uuid do |t|
      t.string :slug
      t.text :description
      t.boolean :active
      t.json :configuration

      t.timestamps
    end
  end
end
