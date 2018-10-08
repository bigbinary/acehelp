# frozen_string_literal: true

class TemporaryArticlesDailyCleanupWorker
  include Sidekiq::Worker

  def perform
    temporary_articles.destroy_all
    logger.info("Temporary articles deleted successfully.")
  end

  private

    def temporary_articles
      TemporaryArticleService.new.article_saved_two_hours_ago
    end
end
