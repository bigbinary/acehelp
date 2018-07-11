# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Resolvers::OrganizationSearchTest < ActiveSupport::TestCase
  setup do
    @article = articles :ror
    @organization = organizations :bigbinary
    @category = categories :novel
    @url = urls :bigbinary

    @article.category = @category
    @article.organization = @organization
    @url.organization = @organization
    @article.save
    @url.save
  end

  test "search organization data success" do
    query = <<-'GRAPHQL'
              query($id: String!) {
                organization(id: $id) {
                  id
                  name
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, id: @organization.id)

    assert_equal result.data.organization.name, @organization.name
  end

  test "search organization data failure" do
    query = <<-'GRAPHQL'
              query($id: String!) {
                organization(id: $id) {
                  id
                  name
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, id: "abcd")

    assert_nil result.data.organization
  end
end
