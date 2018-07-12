class RemoveIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :articles, :category_id
    remove_index :article_urls, :article_id
    remove_index :article_urls, :url_id
    remove_foreign_key :urls, :organizations
    remove_foreign_key :articles, :organizations
  end
end
