# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::UrlMutationsTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  setup do
    @user = users(:brad)
    sign_in @user
    org = organizations :bigbinary
    @url = org.urls.create!(url: "http://test.com")
  end

  test "create url mutations" do
    query = <<-'GRAPHQL'
              mutation($input: CreateUrlInput!) {
                addUrl(input: $input) {
                  url {
                    id
                    url
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { url_pattern: "http://test_url.com" })

    assert_equal result.data.add_url.url.url_pattern, "http://test_url.com"
  end

  test "create url failure" do
    query = <<-'GRAPHQL'
              mutation($input: CreateUrlInput!) {
                addUrl(input: $input) {
                  url {
                    id
                    url
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { url_pattern: "wrong_url" })
    assert_nil result.data.add_url.url_pattern
  end

  test "update url mutations" do
    query = <<-'GRAPHQL'
              mutation ($url: String!, $id: String!) {
                updateUrl(input: { url: $url, id: $id }) {
                  url {
                    id
                    url
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, id: @url.id, url_pattern: "http://test_update_url.com")

    assert_equal result.data.update_url.url.url_pattern, "http://test_update_url.com"
  end

  test "update url mutation failure" do
    query = <<-'GRAPHQL'
              mutation ($url: String!, $id: String!) {
                updateUrl(input: {url: $url, id: $id}) {
                  url {
                    id
                    url
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, id: @url.id, url: "wrong url")
    assert_nil result.data.update_url.url
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
