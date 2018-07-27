# frozen_string_literal: true

require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @organization = organizations :bigbinary
    @headers = { "api-key": @organization.api_key }
  end

  def test_index
    sign_in users(:brad)
    get organization_articles_path(@organization.api_key), headers: @headers

    assert_response :success
  end

  def test_index_failure
    get organization_articles_path(@organization.api_key)
    assert_response 401

    get organization_articles_path(@organization.api_key), headers: @headers
    assert_response 302
  end
end
