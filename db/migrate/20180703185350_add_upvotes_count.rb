class AddUpvotesCount < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :upvotes_count, :int, default: 0
  end
end
