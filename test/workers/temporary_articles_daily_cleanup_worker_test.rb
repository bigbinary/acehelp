# frozen_string_literal: true

require "test_helper"
class TemporaryArticlesDailyCleanupWorkerTest < ActiveSupport::TestCase
  require "sidekiq/testing"

  def setup
    Sidekiq::Testing.fake!

    article = articles(:life)
    article.update_attributes(temporary: true)
    article = articles(:ror)
    article.update_attributes(temporary: true)
  end

  def test_deletes_all_article_with_temporary_true
    assert_equal Article.count, 2
    TemporaryArticlesDailyCleanupWorker.new.perform
    assert_equal Article.count, 0
  end
end
