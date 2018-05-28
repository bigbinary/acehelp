# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[5.2]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :desc, null: false
      t.references(:category, index: true)

      t.timestamps
    end
  end
end
