# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::ArticleMutationsTest < ActiveSupport::TestCase
  setup do
    @category = categories :novel
    @url = urls :bigbinary
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

    result = AceHelp::Client.execute(query, input: { title: "Create Article", desc: "New article creation", category_ids: [@category.id], url_ids: [@url.id] })

    assert_equal result.data.add_article.article.title, "Create Article"
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

    result = AceHelp::Client.execute(query, input: { title: "", desc: "New article creation", category_ids: [@category.id], url_ids: [@url.id] })
    assert_nil result.data.add_article.article
  end


  test "create article invalid title failure with error types" do
    query = <<-'GRAPHQL'
              mutation($input: CreateArticleInput!) {
                addArticle(input: $input) {
                  article {
                    id
                    title
                  }
                  errors {
                    path
                    message
                  }
                }
              }
    GRAPHQL

    result = AceHelp::Client.execute(query, input: { title: "", desc: "New article creation", category_ids: [@category.id], url_ids: [@url.id] })
    assert_not_empty result.data.add_article.errors.flat_map(&:path) & ["addArticle", "title"]
  end


  test "update article mutations" do
    category = categories :autobiography
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

    result = AceHelp::Client.execute(query, input: { id: @article.id, title: "update_test_article", desc: "none", category_id: category.id })

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

    result = AceHelp::Client.execute(query, input: { id: @article.id, title: "", desc: "none", category_id: @category.id })
    assert_nil result.data.update_article.article
  end

  test "update article failure with errors" do
    query = <<-'GRAPHQL'
              mutation($input: UpdateArticleInput!) {
                updateArticle(input: $input) {
                  article {
                    id
                    title
                  }
                  errors {
                    path
                    message
                  }
                }
              }
    GRAPHQL

    result = AceHelp::Client.execute(query, input: { id: @article.id, title: "", desc: "none", category_id: @category.id })

    assert_not_empty result.data.update_article.errors.flat_map(&:path) & ["updateArticle", "title"]
  end

  test "delete article mutations" do
    query = <<-'GRAPHQL'
              mutation($input: DestroyArticleInput!) {
                deleteArticle(input: $input) {
                  deletedId
                }
              }
            GRAPHQL

    result = AceHelp::Client.execute(query, input: { id: @article.id })

    assert_equal result.data.delete_article.deleted_id, @article.id
  end

  test "update article status mutations" do
    mutation = <<-'GRAPHQL'
              mutation($input: UpdateStatusInput!) {
                updateArticleStatus(input: $input) {
                  article {
                    id
                    status
                  }
                  errors {
                    message
                    path
                  }
                }
              }
    GRAPHQL

    result = AceHelp::Client.execute(mutation, input: { id: @article.id, status: "online" })
    assert_equal result.data.update_article_status.article.status, "online"
  end

  test "update article status mutation failure" do
    mutation = <<-'GRAPHQL'
              mutation($input: UpdateStatusInput!) {
                updateArticleStatus(input: $input) {
                  article {
                    id
                    status
                  }
                  errors {
                    message
                    path
                  }
                }
              }
    GRAPHQL

    assert_raises (ArgumentError) do
      AceHelp::Client.execute(mutation, input: { id: @article.id, status: "invalid" })
    end
    # assert_not_empty result.data.update_article_status.errors.flat_map(&:path) & ["updateArticleStatus", "attribute", "status"]
  end
end
