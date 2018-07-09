class AddUuidToEveryTable < ActiveRecord::Migration[5.2]
  def up
    tables = %w[articles article_urls categories contacts organizations urls users]

    tables.each do |table|
      add_column table, :uuid, :uuid, default: "gen_random_uuid()", null: false
    end
  end
end
