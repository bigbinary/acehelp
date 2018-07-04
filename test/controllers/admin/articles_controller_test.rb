# frozen_string_literal: true

require "test_helper"

class Admin::ArticlesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def test_index_returns
    get admin_articles_url

    assert_response 302
  end

  def test_index_returns_success_when_user_is_logged_in
    sign_in users(:brad)
    get admin_articles_url

    assert_response :success
  end
end
