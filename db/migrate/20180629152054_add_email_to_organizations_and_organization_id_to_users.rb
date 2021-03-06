# frozen_string_literal: true

class AddEmailToOrganizationsAndOrganizationIdToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :organizations, :email, :string
    add_reference :users, :organization, foreign_key: true

    Organization.where(email: nil).each do |org|
      org.email = User.first&.email || "email@example.com"
      org.save
    end

    change_column :organizations, :email, :string, null: false
  end

  def down
    remove_column :organizations, :email
    remove_column :users, :organization_id
  end
end
