class RemoveDeviseTokenAuthColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :provider
    remove_column :users, :uid
    remove_column :users, :tokens
  end
end
