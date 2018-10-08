# frozen_string_literal: true

require "test_helper"

class UrlCategoryTest < ActiveSupport::TestCase
  def setup
    @category = categories :autobiography
    @url = urls :google
  end

  test "add url for category" do
    url_categories_count = UrlCategory.count
    @category.urls.destroy_all
    @category.urls << @url

    assert_equal UrlCategory.count, url_categories_count
  end

  test "add same url to category throw error" do
    assert_raises ActiveRecord::RecordInvalid do
      @category.urls << @url
    end
  end
end
