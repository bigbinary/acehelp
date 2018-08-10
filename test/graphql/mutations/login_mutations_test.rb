# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::LoginMutationsTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @ethan = users(:hunt)
    @ethan.password = @ethan.password_confirmation = "SelfDestructIn5"
    @ethan.save
    sign_in @ethan
    @query = <<-GRAPHQL
              mutation($login_keys: LoginUserInput!) {
                  loginUser(input: $login_keys) {
                    token {
                      uid
                    }
                    errors {
                      message
                      path
                    }
                  }
              }
    GRAPHQL
  end

  test "Authentication Token should present" do
    result =  AceHelp::Client.execute(@query, login_keys: { email: @ethan.email, password: "SelfDestructIn5" })
    assert_equal @ethan.email, result.data.login_user.uid
  end

  test "With wrong password" do
    result =  AceHelp::Client.execute(@query, login_keys: { email: @ethan.email, password: "IamWeak" })
    assert_not_empty result.data.login_user.errors.flat_map(&:path) & ["loginUser"]
  end
end
