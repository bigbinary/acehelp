# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require 'simplecov'
SimpleCov.start

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "knapsack"
require "minitest/ci"

Minitest::Ci.report_dir = "reports" if ENV["CI"]
knapsack_adapter = Knapsack::Adapters::MinitestAdapter.bind
knapsack_adapter.set_test_helper_path(__FILE__)

if Rails.application.config.colorize_logging
  require "minitest/reporters"
  require "minitest/pride"

  # Refer https://github.com/kern/minitest-reporters#caveats
  # If you want to see full stacktrace then just use
  # MiniTest::Reporters.use!

  MiniTest::Reporters.use! Minitest::Reporters::ProgressReporter.new,
                           ENV,
                           Minitest.backtrace_filter
end

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests
    # in alphabetical order.
    fixtures :all

    # disable callbacks
    Searchkick.disable_callbacks

    # Add more helper methods to be used by all tests here...
  end
end
