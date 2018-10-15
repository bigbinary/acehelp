# frozen_string_literal: true

require "test_helper"

class AppUrlCarrierTest < ActiveSupport::TestCase
  def test_app_url_when_heroku_app_url_env_variable_is_present
    ENV["HEROKU_APP_URL"] = "https://app.acehelp.com"

    app_url = AppUrlCarrier.app_url

    assert_equal app_url, URI("https://app.acehelp.com")

    ENV["HEROKU_APP_URL"] = nil
  end

  def test_app_url_when_heroku_app_name_env_variable_is_present
    ENV["HEROKU_APP_NAME"] = "acehelp-staging-pr-123"

    app_url = AppUrlCarrier.app_url

    assert_equal app_url, URI("https://acehelp-staging-pr-123.herokuapp.com")

    ENV["HEROKU_APP_NAME"] = nil
  end

  def test_app_url_when_app_url_env_variable_is_present
    ENV["APP_URL"] = "https://staging.acehelp.com"

    app_url = AppUrlCarrier.app_url

    assert_equal app_url, URI("https://staging.acehelp.com")

    ENV["APP_URL"] = nil
  end

  def test_app_url_when_request_is_present
    request = ActionDispatch::Request.new(
      "rack.url_scheme" => "http",
      "HTTP_HOST" => "localhost:3333",
      "PATH_INFO" => "/graphql"
    )

    app_url = AppUrlCarrier.app_url(request)

    assert_equal app_url, URI("http://localhost:3333")
  end

  def test_app_url_when_no_environment_variable_is_set_and_request_is_absent
    app_url = AppUrlCarrier.app_url

    assert_equal app_url, URI("http://localhost:3000")
  end
end
