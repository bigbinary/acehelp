# frozen_string_literal: true

require "test_helper"

class UrlTest < ActiveSupport::TestCase
  def test_url_validation
    url = urls :google
    assert url.valid?

    url.url_pattern = "http://google.com"
    assert url.valid?

    url.url_pattern = "http://*.com"
    assert url.valid?

    url.url_pattern = nil
    assert_not url.valid?
  end
end
