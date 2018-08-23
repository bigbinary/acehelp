# frozen_string_literal: true

require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  def test_category_validation
    category = categories :novel
    assert category.valid?

    category.name = ""
    assert_not category.valid?
    assert category.errors.added?(:name, :blank)
  end

  def test_category_status
    category = categories :novel
    assert category.online?

    category.offline!
    assert category.offline?
  end
end
