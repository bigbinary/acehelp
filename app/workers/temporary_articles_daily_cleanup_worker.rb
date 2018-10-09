# frozen_string_literal: true

class TemporaryArticlesDailyCleanupWorker
  include Sidekiq::Worker

  def perform
    TemporaryArticlesCleanupService.new.process
    logger.info("Temporary articles deleted successfully.")
  end
end
