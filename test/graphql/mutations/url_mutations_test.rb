# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::UrlMutationsTest < ActiveSupport::TestCase
  setup do
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

    result = AceHelp::Client.execute(query, input: { url: "http://test_url.com" })

    assert_equal result.data.add_url.url.url, "http://test_url.com"
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

    assert_raises(Graphlient::Errors::ExecutionError) do
      result = AceHelp::Client.execute(query, input: { url: "wrong_url" })
    end
  end

  test "update url mutations" do
    query = <<-'GRAPHQL'
              mutation($input: UpdateUrlInput!) {
                updateUrl(input: $input) {
                  url {
                    id
                    url
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { id: @url.id, url: { url: "http://test_update_url.com" } })

    assert_equal result.data.update_url.url.url, "http://test_update_url.com"
  end

  test "delete url mutations" do
    query = <<-'GRAPHQL'
              mutation($input: DestroyUrlInput!) {
                destroyUrl(input: $input) {
                  deletedId
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { id: @url.id })

    assert_equal result.data.destroy_url.deleted_id.to_i, @url.id
  end
end
