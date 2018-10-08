# frozen_string_literal: true

class DailyDeleteTemporaryArticleWorker
  include Sidekiq::Worker

  def perform
    temporary_articles.destroy_all
    logger.info("Temporary articles deleted successfully.")
  end

  private

    def temporary_articles
      Article.temporary_articles
    end
end
