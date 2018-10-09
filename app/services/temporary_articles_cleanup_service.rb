# frozen_string_literal: true

class TemporaryArticlesCleanupService
  def initialize
    @articles = Article.temporary_articles
  end

  def process
    article_saved_two_hours_ago.destroy_all
  end

  private

    def article_saved_two_hours_ago
      @articles.article_saved_two_hours_ago
    end
end
