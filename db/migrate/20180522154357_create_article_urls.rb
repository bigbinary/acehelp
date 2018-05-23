class CreateArticleUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :article_urls do |t|
    	t.integer :article_id, null: false
    	t.integer :url_id, null: false
      t.timestamps
    end

    add_index :article_urls, :article_id
    add_index :article_urls, :url_id
  end
end
