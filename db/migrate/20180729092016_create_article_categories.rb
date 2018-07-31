class CreateArticleCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :article_categories, id: :uuid do |t|
      t.uuid :category_id, default: "gen_random_uuid()", null: false
      t.uuid :article_id, default: "gen_random_uuid()", null: false
      t.timestamps
    end

    add_foreign_key :article_categories, :articles
    add_foreign_key :article_categories, :categories
  end
end
