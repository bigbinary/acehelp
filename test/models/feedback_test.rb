require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  def setup
    @article = articles(:life)
  end

  test "valid feedback" do
    valid_feedback = feedbacks(:valid_feedback)
    assert valid_feedback.valid?
  end

  test "invalid feedback" do
    invalid_feedback = feedbacks(:second_feedback)
    invalid_feedback.message = nil
    assert_raise(ActiveRecord::RecordInvalid) do
      invalid_feedback.save!
    end
  end
end
