# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::ArticleMutationsTest < ActiveSupport::TestCase
  setup do
    @category = categories :novel
    org = organizations :bigbinary
    @article = @category.articles.create!(title: "test_article", desc: "Only for test",  organization_id: org.id)
  end

  test "create article mutations" do
    query = <<-'GRAPHQL'
              mutation($input: CreateArticleInput!) {
                addArticle(input: $input) {
                  article {
                    id
                    title
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { title: "Create Article", desc: "New article creation", category_id: @category.id })

    assert_equal result.data.add_article.article.title, "Create Article"
  end

  test "create article failure" do
    query = <<-'GRAPHQL'
              mutation($input: CreateArticleInput!) {
                addArticle(input: $input) {
                  article {
                    id
                    title
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { title: "Create Article", desc: "New article creation", category_id: "" })

    assert_nil result.data.add_article.article
  end

  test "create article invalid title failure" do
    query = <<-'GRAPHQL'
              mutation($input: CreateArticleInput!) {
                addArticle(input: $input) {
                  article {
                    id
                    title
                  }
                }
              }
            GRAPHQL

    assert_raises(Graphlient::Errors::ExecutionError) do
      AceHelp::Client.execute(query, input: { title: "", desc: "New article creation", category_id: @category.id })
    end
  end

  test "update article mutations" do
    query = <<-'GRAPHQL'
              mutation($input: UpdateArticleInput!) {
                updateArticle(input: $input) {
                  article {
                    id
                    title
                  }
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { id: @article.id, article: { title: "update_test_article", desc: "none", category_id: @category.id } })

    assert_equal result.data.update_article.article.title, "update_test_article"
  end

  test "update article failure" do
    query = <<-'GRAPHQL'
              mutation($input: UpdateArticleInput!) {
                updateArticle(input: $input) {
                  article {
                    id
                    title
                  }
                }
              }
            GRAPHQL

    assert_raises(Graphlient::Errors::ExecutionError) do
      AceHelp::Client.execute(query, input: { id: @article.id, article: { title: "", desc: "none", category_id: @category.id } })
    end
  end

  test "delete article mutations" do
    query = <<-'GRAPHQL'
              mutation($input: DestroyArticleInput!) {
                destroyArticle(input: $input) {
                  deletedId
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { id: @article.id })

    assert_equal result.data.destroy_article.deleted_id.to_i, @article.id
  end
end
