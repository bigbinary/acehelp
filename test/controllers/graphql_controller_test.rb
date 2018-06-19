# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class GraphqlControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles :ror
    @organization = organizations :bigbinary
    @category = categories :novel
    @url = urls :google

    @article.category = @category
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
end
