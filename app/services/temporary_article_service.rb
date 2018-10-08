# frozen_string_literal: true

class TemporaryArticleService
  def initialize
    @articles = Article.temporary_articles
  end

  def article_saved_two_hours_ago
    @articles.article_saved_two_hours_ago
  end
end
