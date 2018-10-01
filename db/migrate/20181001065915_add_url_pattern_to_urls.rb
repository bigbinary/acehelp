class AddUrlPatternToUrls < ActiveRecord::Migration[5.2]
  def change
    add_column :urls, :url_rule, :string, nil: false
    add_column :urls, :url_pattern, :string, nil: false
    remove_column :urls, :url
  end
end
