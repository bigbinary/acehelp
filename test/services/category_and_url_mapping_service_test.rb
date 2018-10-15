# frozen_string_literal: true

require "test_helper"

class CategoryAndUrlMappingServiceTest < ActiveSupport::TestCase
  require "sidekiq/testing"
  def setup
    @user = users(:brad)
    @org = organizations :bigbinary
    @url = @org.urls.create!(url_pattern: "http://test.com", url_rule: "contains")
    categories :novel
    categories :autobiography
  end

  def test_assign_categories_to_url
    CategoryAndUrlMappingService.new(@url.id, Category.all.pluck(:id), @org).process
    assert_equal @url.categories.count, Category.count
    assert_equal @url.categories, Category.all
  end
end
