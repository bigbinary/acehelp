# frozen_string_literal: true

require "test_helper"

class Resolvers::FeedbacksSearchTest < ActiveSupport::TestCase
  setup do
    @feedback = feedbacks :ror_feedback
    @article = @feedback.article
    @organization = @article.organization
  end

  def find(args)
    Resolvers::FeedbacksSearch.new.call(nil, args, organization: @organization)
  end

  test "get_all_feedbacks_success" do
    assert_equal ["Harely Davidson", "Sam"], find(status: "open").pluck(:name)
  end

  test "feedbacks with article id" do
    assert_equal ["Harely Davidson", "Sam"], find(status: "open", article_id: @article.id).pluck(:name)
  end
end
