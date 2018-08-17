# frozen_string_literal: true


require 'test_helper'

class TriggerTest < ActiveSupport::TestCase
  def setup
    @triggers = triggers
  end

  def scope_active_test
    assert_equal [true], Trigger.active.distinct.pluck(:active)
  end

  def scope_inactive_test
    assert_equal [false], Trigger.inactive.distinct.pluck(:active)
  end

end
