# frozen_string_literal: true

require "test_helper"

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  def test_new_org
    get new_organization_url
    assert_response 302
  end
end
