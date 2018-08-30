class AddStatusToArticle < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :status, :string, default: :inactive, null: false
  end
end
