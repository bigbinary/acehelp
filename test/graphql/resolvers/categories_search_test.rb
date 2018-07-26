# frozen_string_literal: true

require "test_helper"

class Resolvers::CategoriesSearchTest < ActiveSupport::TestCase
  setup do
    @organization = organizations :bigbinary
  end

  def find
    Resolvers::CategoriesSearch.new.call(nil, {}, { organization: @organization })
  end

  test "get_all_categories_success" do
    assert_equal find.pluck(:name), ["AutoBioGraphy", "Novel"]
  end
end
