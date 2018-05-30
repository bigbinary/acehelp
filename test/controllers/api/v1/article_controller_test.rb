# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class ArticleControllerTest < ActionDispatch::IntegrationTest
      setup do
        @article = articles :ror
      end

      def test_show_article_success
        get api_v1_article_url(@article.id), params: { format: :json }

        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @article.title, json.first.second["title"]
      end

      def test_show_article_failure
        get api_v1_article_url(-1), params: { format: :json }

        assert_response :not_found
      end

      def test_search_article
        get api_v1_articles_search_url

        assert_response :success
        get api_v1_articles_search_url, params: { query: "Ruby" }

        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @article.title, json.first.second.first["title"]
      end
    end
  end
end
