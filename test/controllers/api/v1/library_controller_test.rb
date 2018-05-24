require "test_helper"

class Api::V1::LibraryControllerTest < ActionDispatch::IntegrationTest
  def test_all_for_categories_and_articles
    category = Category.create!(name: "Magzine")
    organization = Organization.create!(name: "BigBinary")
    article = Article.create!(title: "Good Wife's Guide", desc: "how a good wife should act", category_id: category.id, organization_id: organization.id)

    get api_v1_all_url, params: { format: :json }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal %w(MyString MyString Magzine), json.first.second.map{|category| category["name"]}
  end

  def test_all_for_no_categories_and_articles
  	Category.delete_all
  	Article.delete_all

  	get api_v1_all_url, params: { format: :json }

    assert_response 404
  end
end