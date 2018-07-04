class AddDownvotesToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :downvotes_count, :int, default: 0
  end
end