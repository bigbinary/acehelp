require 'test_helper'

class EmbedControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations :aceinvoice
  end

  def test_embed_js_returns_success_response_when_valid_api_key_is_passed
    get embed_js_url, params: { api_key: @organization.api_key}

    assert_response :success
  end

  def test_embed_js_returns_error_when_invalid_key_is_passed
    get embed_js_url, params: { api_key: "" }

    assert_response :bad_request
  end

  def test_embed_js_returns_error_when_api_key_is_missing_in_param
    get embed_js_url

    assert_response :bad_request
  end
end
