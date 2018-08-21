# frozen_string_literal: true

require "test_helper"

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  def test_new_org
    get new_organization_url

    assert_response 302
  end

  def test_new_org_with_user_logged_in
    get new_organization_url, headers: users(:brad).create_new_auth_token

    assert_response :success
  end
end
