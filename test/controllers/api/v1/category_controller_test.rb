# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class CategoryControllerTest < ActionDispatch::IntegrationTest
      setup do
        @article = articles :ror
        @organization = organizations :bigbinary
        @category = categories :novel
        @url = urls :google

        @article.category = @category
        @article.organization = @organization
        @url.organization = @organization
        @article.save
        @url.save
      end

      def test_all_for_categories_and_articles
        get api_v1_all_url, params: { format: :json }

        assert_response :success
        json = JSON.parse(response.body)
        assert_equal(
          %w[AutoBioGraphy Novel],
          json.first.second.map { |category| category["name"] }
        )
      end

      def test_all_for_no_categories_and_articles
        ArticleUrl.delete_all
        Article.delete_all
        Category.delete_all


        get api_v1_all_url, params: { format: :json }

        assert_response 200
      end
    end
  end
end
