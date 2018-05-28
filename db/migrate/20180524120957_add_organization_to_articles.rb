# frozen_string_literal: true

class AddOrganizationToArticles < ActiveRecord::Migration[5.2]
  def change
    add_reference :articles, :organization, foreign_key: true
  end
end
