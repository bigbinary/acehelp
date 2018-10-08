class CreateUrlCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :url_categories, id: :uuid do |t|
      t.integer :category_id, null: false
      t.integer :url_id, null: false
      t.timestamps
    end
    add_index :url_categories, :category_id
    add_index :url_categories, :url_id
  end
end
