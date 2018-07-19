class AddOrganizationIdAsForeignKey < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :urls, :organizations
    add_foreign_key :articles, :organizations
    add_foreign_key :users, :organizations
  end
end
