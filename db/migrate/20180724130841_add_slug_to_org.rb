class AddSlugToOrg < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :slug, :string, null: false
    add_index :organizations, :slug, unique: true
  end
end
