# frozen_string_literal: true

require 'test_helper'

class Admin::OrganizationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def test_new_org
    get new_organization_url

    assert_response 302
  end

  def test_new_org_with_user_logged_in
    sign_in users(:brad)
    get new_organization_url

    assert_response :success
  end
end
