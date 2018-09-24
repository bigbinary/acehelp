class AddUniqueIndexToCategory < ActiveRecord::Migration[5.2]
  def change
    add_index :categories, [:name, :organization_id], unique: true
  end
end
