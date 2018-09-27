# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::WidgetSettingMutationsTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  setup do
    @setting = settings :bigbinary
    @org = organizations :bigbinary
    @user = users(:brad)
    sign_in @user
  end

  test "create widget settings mutations" do
    query = <<-'GRAPHQL'
              mutation($input: UpdateSettingsInput!) {
                updateBaseUrlForOrganization(input: $input) {
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

    assert_equal result.data.update_base_url_for_organization.setting.base_url, "http://bigbinary.com"
  end

  test "fail saving settings with same base_url" do
    query = <<-'GRAPHQL'
              mutation($input: UpdateSettingsInput!) {
                updateBaseUrlForOrganization(input: $input) {
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

    assert_raises ActiveRecord::RecordInvalid do
      AceHelp::CustomClient.call(organizations(:aceinvoice).api_key).execute(query, input: { base_url: "http://bigbinary.com" })
    end
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
