# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::CategoryArticleMutationsTest < ActiveSupport::TestCase
  setup do
    @category = categories :novel
    org = organizations :bigbinary
    @article = articles :life
  end

  test "add_category_to_article_mutation" do
    query = <<-'GRAPHQL'
              mutation($input: AddCategoryToArticleInput!) {
                addCategoryToArticle(input: $input) {
                  article {
                    id,
                    title
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { category_id: @category.id, article_id: @article.id },)

    assert_equal result.data.add_category_to_article.article.title, "Happiest day of your life"
  end

  test "remove_category_from_article_mutation" do
    category = categories :autobiography
    query = <<-'GRAPHQL'
              mutation($input: RemoveCategoryFromArticleInput!) {
                removeCategoryFromArticle(input: $input) {
                  article {
                    id,
                    title
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { category_id: category.id, article_id: @article.id })

    assert_equal result.data.remove_category_from_article.article.title, "Happiest day of your life"
  end
end
