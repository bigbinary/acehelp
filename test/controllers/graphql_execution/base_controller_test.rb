# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class GraphqlExecution::BaseControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles :ror
    @organization = organizations :bigbinary
    @category = categories :novel
    @url = urls :google

    @article.organization = @organization
    @url.organization = @organization
    @article.save
    @url.save
    @headers = { "api-key": @organization.api_key }
  end

  test "Invalid graphql query failure" do
    query = <<-'GRAPHQL'
              "string"
            GRAPHQL

    assert_raises(GraphQL::ParseError) do
      result = AceHelp::Client.execute(query)
    end

    query = <<-'GRAPHQL'
              ["List"]
            GRAPHQL

    assert_raises(GraphQL::ParseError) do
      result = AceHelp::Client.execute(query)
    end
  end

  test "Sets 'widget_installed' to 'true' when 'X-Client' request header has 'widget' value" do
    assert_not @organization.reload.setting.widget_installed

    post "/graphql",
         params: { query: "query { organizations { id name widget_visibility }}" },
         headers: { "api-key": @organization.api_key, "X-Client": "widget" }

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

    assert @organization.reload.setting.widget_installed
  end

  test "Does nothing when 'X-Client' request header does not have 'widget' value" do
    assert_not @organization.reload.setting.widget_installed

    post "/graphql",
         params: { query: "query { organizations { id name widget_visibility }}" },
         headers: { "api-key": @organization.api_key, "X-Client": "dashboard" }

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
