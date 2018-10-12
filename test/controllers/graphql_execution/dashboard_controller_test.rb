# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class GraphqlExecution::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles :ror
    @organization = organizations :bigbinary
    @category = categories :novel
    @url = urls :google

    @article.organization = @organization
    @url.organization = @organization
    @article.save
    @url.save
  end

  test "No change is made to 'Setting#widget_installed' attribute" do
    assert_not @organization.reload.setting.widget_installed

    post "/graphql_execution/dashboard",
         params: { query: "query { organizations { id name widget_visibility }}" },
         headers: { "api-key": @organization.api_key }

    expected_response = {
      "data" => {
        "organizations" => {
          "id" => @organization.id,
          "name" => @organization.name,
          "widget_visibility" => @organization.setting.enable?
        }
      }
    }

    assert_response :success

    assert_equal(expected_response, response.parsed_body)

    assert_not @organization.reload.setting.widget_installed
  end
end
