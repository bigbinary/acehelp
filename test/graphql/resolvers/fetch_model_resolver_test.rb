# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Resolvers::OrganizationSearchTest < ActiveSupport::TestCase
  setup do
    @article = articles :ror
    @organization = organizations :bigbinary
    @category = categories :novel
    @article.category = @category
    @article.organization = @organization
    @article.save!
  end

  test "search article data success" do
    query = <<-'GRAPHQL'
              query($id: Int!) {
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
              query($id: Int!) {
                article(id: $id) {
                  id
                  title
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, id: -1)

    assert_nil result.data.article
  end
end
