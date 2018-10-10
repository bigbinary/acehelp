class AddWidgetInstalledToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :widget_installed, :boolean, default: false, null: false
  end
end
