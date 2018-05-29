# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class ArticleControllerTest < ActionDispatch::IntegrationTest
      setup do
        @article = articles :ror
        @url = urls :google
        ArticleUrl.create!(article_id: @article.id, url_id: @url.id)
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

      def test_index_article_success
        get api_v1_article_index_url, params: { url: @url.url }

        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @article.title, json.first.second.first["title"]
      end

      def test_index_article_failure
        get api_v1_article_index_url, params: { url: nil }

        assert_response :bad_request
        get api_v1_article_index_url, params: { url: "random_url" }

        assert_response :not_found
      end
    end
  end
end
