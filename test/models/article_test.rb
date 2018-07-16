# frozen_string_literal: true

require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  def test_article_validation
    article = articles :ror
    assert article.valid?
  end

  def setup
    Searchkick.enable_callbacks
  end

  def teardown
    Searchkick.disable_callbacks
  end

  def test_search
    c1 = Category.create! name: "Code"
    org = Organization.create! name: "Google", email: "google@google.com"
    c1.articles.create!(
      title: "How do I put nodejs code in my website?",
      desc: "coming soon",
      organization_id: org.id
    )

    Article.reindex

    assert_equal ["How do I put nodejs code in my website?"], Article.search("nodejs").map(&:title)
  end
end
