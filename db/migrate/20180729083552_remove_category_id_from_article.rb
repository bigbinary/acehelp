class RemoveCategoryIdFromArticle < ActiveRecord::Migration[5.2]
  def up
    remove_column :articles, :category_id
  end

  def down
    add_column :articles, :category_id, :uuid, default: "gen_random_uuid()", null: false
  end
end
