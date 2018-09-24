# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = users :brad
    sign_in @user
  end

  def test_redirection_after_sign_out
    delete destroy_user_session_url
    assert_redirected_to root_path
  end
end
