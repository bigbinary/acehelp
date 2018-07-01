# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class ArticleControllerTest < ActionDispatch::IntegrationTest
      setup do
        @article = articles :ror
        @url = urls :google
        @organization = organizations :bigbinary
        @category = categories :autobiography
        ArticleUrl.create!(article_id: @article.id, url_id: @url.id)

        @search_article = Article.create!(
          title: "How to do search with elasticsearch",
          desc: "Learn elasticsearch",
          category_id: @category.id,
          organization_id: @organization.id
        )
      end

      def test_show_article_success
        get api_v1_article_url(@article.id), params: { format: :json }

        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @article.title, json["article"]["title"]
      end

      def test_show_article_failure
        get api_v1_article_url(-1), params: { format: :json }

        assert_response :not_found
      end

      def test_index_article_success
        get api_v1_article_index_url, params: { url: @url.url }

        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @article.title, json["articles"].first["title"]
      end

      def test_index_article_failure
        get api_v1_article_index_url, params: { url: nil }

        assert_response :bad_request

        get api_v1_article_index_url, params: { url: "random_url" }

        assert_response :not_found
      end

      def test_search_article
        Article.reindex

        get api_v1_articles_search_url, params: {}

        assert_response :success
        json = JSON.parse(response.body)
        assert_equal json["articles"].size, 0

        get api_v1_articles_search_url, params: { query: "search" }

        assert_response :success
        json = JSON.parse(response.body)
        assert_equal "How to do search with elasticsearch", json["articles"].first["title"]
      end
    end
  end
end
