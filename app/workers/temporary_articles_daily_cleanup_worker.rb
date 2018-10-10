# frozen_string_literal: true

class TemporaryArticlesDailyCleanupWorker
  include Sidekiq::Worker

  def perform
    TemporaryArticlesCleanupService.new.process
  end
end
