# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Resolvers::OrganizationSearchTest < ActiveSupport::TestCase
  setup do
    @article = articles :ror
    @organization = organizations :bigbinary
    @category = categories :novel
    @article.organization = @organization
    @article.save!
  end

  test "search article data success" do
    query = <<-'GRAPHQL'
              query($id: String!) {
                article(id: $id) {
                  id
                  title
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, id: @article.id)

    assert_equal result.data.article.title, @article.title
  end

  test "search article data failure" do
    query = <<-'GRAPHQL'
              query($id: String!) {
                article(id: $id) {
                  id
                  title
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, id: "abcd")

    assert_nil result.data.article
  end
end
