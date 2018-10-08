class CreateUrlCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :url_categories, id: :uuid do |t|
      t.uuid :category_id, default: "gen_random_uuid()", null: false
      t.uuid :url_id, default: "gen_random_uuid()", null: false
      t.timestamps
    end
    add_index :url_categories, :category_id
    add_index :url_categories, :url_id
  end
end
