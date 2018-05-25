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
  end
  
  def test_index_success
    get url_index_url, params: nil, headers: { "api-key": @organization.api_key }
    
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "http://google.com", json.first.second.first["url"]
  end

  def test_create_success
    post url_index_url, params: { url: { url: "https://amazon.com" } }, headers: { "api-key": @organization.api_key }
    assert_response :success
  end

  def test_update_success
    put url_path(@url.id), params: { url: { url: "https://amazon.com" } }, headers: { "api-key": @organization.api_key }
    assert_response :success
  end

  def test_destroy_success
    delete url_path(@url.id), params: nil, headers: { "api-key": @organization.api_key }
    assert_response :success
  end

end
