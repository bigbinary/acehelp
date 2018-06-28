# frozen_string_literal: true

class AddEmailToOrganizationsAndOrganizationIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :email, :string
    add_column :users, :organization_id, :string
  end
end
