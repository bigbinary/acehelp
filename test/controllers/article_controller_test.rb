require "test_helper"

class ArticleControllerTest < ActionDispatch::IntegrationTest
  
  def test_index_success
    organization = Organization.create!(name: "Bigbinary")
    url = Url.create!(url: "https://google.com", organization_id: organization.id)
    category = Category.create!(name: "Magzine")
    article = Article.create!(title: "Good Wife's Guide", desc: "how a good wife should act", category_id: category.id, organization_id: organization.id)
    ArticleUrl.create!(url_id: url.id, article_id: article.id)
    
    get article_index_url, params: { url: "https://google.com" }, as: :json
    
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Good Wife's Guide", json.first.second.first["title"]
  end

end