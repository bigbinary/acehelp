# frozen_string_literal: true

require "test_helper"

class UrlControllerTest < ActionDispatch::IntegrationTest
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
    @headers = { "api-key": @organization.api_key }
  end

  def test_index_success
    get url_index_url, params: nil, headers: @headers

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "http://google.com", json.first.second.second["url"]
  end

  def test_create_success
    params = { url: { url: "https://amazon.com" } }
    post url_index_url, params: params, headers: @headers

    assert_response :success
  end

  def test_create_failure
    params = { url: { url: "invalid_url" } }
    post url_index_url, params: params, headers: @headers

    assert_response :unprocessable_entity
  end

  def test_update_success
    params = { url: { url: "https://amazon.com" } }
    put url_path(-345), params: params, headers: @headers

    assert_response :not_found

    put url_path(@url.id), params: params, headers: @headers

    assert_response :success
  end

  def test_update_failure
    params = { url: { url: "invalid_url" } }

    put url_path(@url.id), params: params, headers: @headers

    assert_response :unprocessable_entity
  end

  def test_destroy_success
    ArticleUrl.delete_all
    Article.delete_all

    delete url_path(@url.id), params: nil, headers: @headers

    assert_response :success
  end
end
