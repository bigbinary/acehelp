class AddStatusToArticle < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :status, :string, default: :active, null: false
  end
end
