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
  end
  
  def test_index_success
    organization = Organization.create!(name: "Amazon")
    url = Url.create!(url: "https://google.com", organization_id: organization.id)
    category = Category.create!(name: "Magzine")
    article = Article.create!(title: "Good Wife's Guide", desc: "how a good wife should act", category_id: category.id, organization_id: organization.id)
    ArticleUrl.create!(url_id: url.id, article_id: article.id)
    
    get article_index_url, params: { url: "https://google.com" }, headers: { "api-key": organization.api_key }
    
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Good Wife's Guide", json.first.second.first["title"]
  end

  def test_index_success_for_organization
    get article_index_url, params: nil, headers: { "api-key": @organization.api_key }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Ruby on rails", json.first.second.first["title"]
  end

  def test_create_success
    post article_index_url, params: { article: { title: "rails", desc: "about framework", category_id: @category.id } }, headers: { "api-key": @organization.api_key }
    assert_response :success
  end

  def test_update_success
    put article_path(@article.id), params: { article: { title: "Rails" } }, headers: { "api-key": @organization.api_key }
    assert_response :success
  end

  def test_destroy_success
    delete article_path(@article.id), params: nil, headers: { "api-key": @organization.api_key }
    assert_response :success
  end

end
