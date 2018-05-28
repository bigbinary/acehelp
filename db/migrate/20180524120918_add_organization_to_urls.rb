# frozen_string_literal: true

class AddOrganizationToUrls < ActiveRecord::Migration[5.2]
  def change
    add_reference :urls, :organization, foreign_key: true
  end
end
