class AddUserAgentAndDeviceInfoInTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :user_agent, :string
    add_column :tickets, :device_info, :json
  end
end
