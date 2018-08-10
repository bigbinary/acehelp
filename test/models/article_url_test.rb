# frozen_string_literal: true

require "test_helper"

class ArticleUrlTest < ActiveSupport::TestCase
  def setup
    @article = articles :life
    @url = urls :google
  end

  test "add url for article" do
    article_url_count = ArticleUrl.count
    @article.urls.destroy_all
    @article.urls << @url

    assert_equal ArticleUrl.count, article_url_count
  end

  test "add same url to throw error" do
    assert_raises ActiveRecord::RecordInvalid do
      @article.urls << @url
    end
  end
end
