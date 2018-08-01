# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::ForgotPasswordMutationsTest < ActiveSupport::TestCase

  setup do
    @ethan = users(:hunt)

    @query = <<-GRAPHQL
              mutation($recover_keys: ForgotPasswordInput!) {
                  forgotPassword(input: $recover_keys) {
                    status
                    errors {
                      message
                      path
                    }
                  }
              }
    GRAPHQL
  end

  test "Successful password recovery request" do
    result =  AceHelp::Client.execute(@query, recover_keys: { email: @ethan.email})
    assert_equal true,  result.data.forgot_password.status
  end

  test "Unsupported email password recovery" do
    result =  AceHelp::Client.execute(@query, recover_keys: { email: "unsupported@email.com" })
    assert_not_empty result.data.forgot_password.errors.flat_map(&:path) & ["forgotPassword"]
  end
end