class AddOrganizationIdAsForeignKey < ActiveRecord::Migration[5.2]
  def change
    unless foreign_key_exists?(:users, :organizations)
      add_foreign_key :users, :organizations
    end
  end
end
