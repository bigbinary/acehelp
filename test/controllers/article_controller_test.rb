# frozen_string_literal: true

require "test_helper"

class ArticleControllerTest < ActionDispatch::IntegrationTest
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
    ArticleUrl.create!(url_id: @url.id, article_id: @article.id)
  end

  def test_index_success
    headers = { "api-key": @organization.api_key }
    params = { url: "http://google.com" }
    get article_index_url, params: params, headers: headers

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Ruby on rails", json.first.second.first["title"]
  end

  def test_index_success_for_organization
    headers = { "api-key": @organization.api_key }
    get article_index_url, params: nil, headers: headers

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Ruby on rails", json.first.second.first["title"]
  end

  def test_create_success
    params = {
      article: {
        title: "rails",
        desc: "about framework",
        category_id: @category.id
      }
    }

    headers = { "api-key": @organization.api_key }

    post article_index_url, params: params, headers: headers

    assert_response :success
  end

  def test_update_success
    params = { article: { title: "rails" } }
    headers = { "api-key": @organization.api_key }

    put article_path(@article.id), params: params, headers: nil

    assert_response :unauthorized

    put article_path(-345), params: params, headers: headers

    assert_response :not_found

    put article_path(@article.id), params: params, headers: headers

    assert_response :success
  end

  def test_destroy_success
    headers = { "api-key": @organization.api_key }

    delete article_path(@article.id), params: { article: { title: "Rails" } }
    assert_response :unauthorized

    delete article_path(@article.id), params: nil, headers: headers

    assert_response :success
  end
end
