# frozen_string_literal: true

require "test_helper"

class UrlTest < ActiveSupport::TestCase
  def test_url_validation
    url = urls :google
    assert url.valid?

    url.url = "google"
    assert_not url.valid?

    url.url = nil
    assert_not url.valid?
  end
end
