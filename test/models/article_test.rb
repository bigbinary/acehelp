# frozen_string_literal: true

require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  def test_article_validation
    article = articles :ror
    assert_not article.valid?

    organization = organizations :bigbinary
    article.organization = organization
    assert_not article.valid?

    category = categories :novel
    article.category = category

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
    org = Organization.create! name: "Google"
    c1.articles.create!(
      title: "How do I put nodejs code in my website?",
      desc: "coming soon",
      organization_id: org.id
    )

    Article.search_index.refresh

    assert_equal ["How do I put nodejs code in my website?"], Article.search("nodejs").map(&:title)
  end
end
