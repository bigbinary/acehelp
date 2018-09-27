class AddTemporaryFlagInArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :temporary, :boolean, default: true
  end
end
