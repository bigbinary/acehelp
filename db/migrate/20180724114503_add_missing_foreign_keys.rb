class AddMissingForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :article_urls, :articles
    add_foreign_key :article_urls, :urls
    add_index :article_urls, :article_id
    add_index :article_urls, :url_id

    add_foreign_key :articles, :categories
    add_foreign_key :articles, :organizations
    add_index :articles, :category_id

    add_foreign_key :urls, :organizations

    add_index :users, :organization_id
  end
end
