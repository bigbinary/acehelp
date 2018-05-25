require 'test_helper'

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
end
