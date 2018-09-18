# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::WidgetSettingMutationsTest < ActiveSupport::TestCase
  setup do
    @setting = settings :bigbinary
    @org = organizations :bigbinary
  end

  test "create widget settings mutations" do
    query = <<-'GRAPHQL'
              mutation($input: SaveSettingsInput!) {
                saveOrganizationWidgetSetting(input: $input) {
                  setting {
                    id
                    base_url
                    organization {
                      id
                    }
                  }
                }
              }
            GRAPHQL

    result = AceHelp::CustomClient.call(organizations(:bigbinary).api_key).execute(query, input: { base_url: "http://bigbinary.com" })

    assert_equal result.data.save_organization_widget_setting.setting.base_url, "http://bigbinary.com"
  end

  test "update widget setting visibility" do
    query = <<-'GRAPHQL'
              mutation($input: EnableDisableWidgetInput!) {
                changeVisibilityOfWidget(input: $input) {
                  setting {
                    id
                    base_url
                    organization {
                      id
                    }
                  }
                }
              }
    GRAPHQL

    result = AceHelp::CustomClient.call(organizations(:bigbinary).api_key).execute(query, input: { visibility: "enable" })

    assert_equal result.data.change_visibility_of_widget.setting.base_url, "http://bigbinary.com"

  end
end
