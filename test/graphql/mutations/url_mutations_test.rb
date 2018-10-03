# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::UrlMutationsTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  setup do
    @user = users(:brad)
    sign_in @user
    org = organizations :bigbinary
    @url = org.urls.create!(url_pattern: "http://test.com", url_rule: "contains")
  end

  test "create url mutations" do
    query = <<-'GRAPHQL'
              mutation($input: CreateUrlInput!) {
                addUrl(input: $input) {
                  url {
                    id
                    url_pattern
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query,
      input: { url_pattern: "http://test_url.com", url_rule: "contains" }
    )

    assert_equal result.data.add_url.url.url_pattern, "http://test_url.com"
  end

  test "create url failure" do
    query = <<-'GRAPHQL'
              mutation($input: CreateUrlInput!) {
                addUrl(input: $input) {
                  url {
                    id
                    url_pattern
                  }
                }
              }
            GRAPHQL

    assert_raises(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(query, input: { url_pattern: "wrong_url" })
    end
  end

  test "update url mutations" do
    query = <<-'GRAPHQL'
              mutation ($id: String!, $url_pattern: String!, $url_rule: String) {
                updateUrl(input: { url_pattern: $url_pattern, url_rule: $url_rule, id: $id }) {
                  url {
                    id
                    url_pattern
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, id: @url.id, url_pattern: "http://test_update_url.com")

    assert_equal result.data.update_url.url.url_pattern, "http://test_update_url.com"
  end

  test "update url mutation failure" do
    query = <<-'GRAPHQL'
              mutation ($id: String!, $url_pattern: String!, $url_rule: String) {
                updateUrl(input: { url_pattern: $url_pattern, url_rule: $url_rule, id: $id }) {
                  url {
                    id
                    url_pattern
                  }
                }
              }
            GRAPHQL

    assert_raises(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(query, id: @url.id)
    end
  end

  test "delete url mutations" do
    query = <<-'GRAPHQL'
              mutation($input: DestroyUrlInput!) {
                deleteUrl(input: $input) {
                  deletedId
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { id: @url.id })

    assert_equal result.data.delete_url.deleted_id, @url.id
  end
end
