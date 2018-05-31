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
    article = articles :ror
    Article.search_index.refresh
    assert_equal ["Ruby on rails"], Article.search("Ruby").map(&:title)
  end
end
