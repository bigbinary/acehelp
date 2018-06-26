# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class OrganizationControllerTest < ActionDispatch::IntegrationTest
      setup do
        @article = articles :ror
        @url = urls :google
        @organization = organizations :bigbinary
        @category = categories :autobiography
        ArticleUrl.create!(article_id: @article.id, url_id: @url.id)
        @url.organization = @organization
        @article.organization = @organization
        @article.category = @category
        @url.save!
        @article.save!
      end

      def test_get_organization_data_failure
        get api_v1_url("-1/data"), params: { format: :json }

        assert_response :not_found
      end

      def test_get_organization_data_success
        get api_v1_url("#{@organization.id}/data"), params: { format: :json }

        assert_response :success
        json = JSON.parse(response.body)
        assert_equal json["organization"]["id"], @organization.id
        assert_equal json["organization"]["name"], "BigBinary"
        assert_equal json["articles"].first["title"], @article.title
        assert_equal json["urls"].first["url"], @url.url
      end
    end
  end
end
