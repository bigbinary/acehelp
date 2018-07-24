class AddOrgIdToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :organization_id, :uuid
    add_foreign_key :categories, :organizations
    add_index :categories, :organization_id
  end
end
