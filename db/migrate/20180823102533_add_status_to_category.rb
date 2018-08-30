class AddStatusToCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :status, :string, null: false, default: 'active'
  end
end
