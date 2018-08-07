class ChangeAgentToCommenterInComments < ActiveRecord::Migration[5.2]
  def up
    add_column :comments, :commentable_type, :string
    rename_column :comments, :agent_id, :commentable_id

    Comment.all.map {|c| c.commentable_type = "Agent"; c.save! }

    change_column :comments, :commentable_type, :string, null: false
  end

  def down
    remove_column :comments, :commentable_type
    rename_column :comments, :commentable_id, :agent_id
  end
end
