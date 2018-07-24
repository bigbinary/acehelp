require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  def setup
    @feedback = feedbacks(:valid_feedback)
  end

  test "valid feedback" do
    valid_feedback = feedbacks(:valid_feedback)
    assert valid_feedback.valid?
  end

  test "invalid feedback" do
    invalid_feedback = feedbacks(:invalid_feedback)
    assert_not invalid_feedback.valid?
  end
end
