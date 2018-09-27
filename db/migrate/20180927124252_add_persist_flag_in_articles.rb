class AddPersistFlagInArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :persist, :boolean, default: false
  end
end
