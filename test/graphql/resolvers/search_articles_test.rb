# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Resolvers::SearchArticlesTest < ActiveSupport::TestCase
  setup do
    @article = articles :ror
  end

  test "search articles query" do
    query = <<-'GRAPHQL'
              query($search_string: String!) {
                searchArticles(search_string: $search_string) {
                  id
                  title
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, search_string: "day")
    assert_not_empty result.data.search_articles
  end
end
