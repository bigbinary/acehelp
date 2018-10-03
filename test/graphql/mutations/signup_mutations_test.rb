# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::SignupMutationsTest < ActiveSupport::TestCase
  setup do
    @signup_mutation = <<-'GRAPHQL'
            mutation($input: SignupInput!) {
              signup(input: $input) {
                user {
                  id,
                  email
                }
                errors {
                  message
                  path
                }
              }
            }
    GRAPHQL
  end

  test "signup mutations" do
    result = AceHelp::Client.execute(@signup_mutation, input: {
      first_name: "morgan",
      last_name: "freeman",
      email: "morgan@example.com",
      password: "welcome",
      confirm_password: "welcome"
    })
    assert_equal result.data.signup.user.email, "morgan@example.com"
    assert_nil result.data.signup.errors
  end

  test "signup when user is already present" do
    user = users :hunt
    result = AceHelp::Client.execute(@signup_mutation, input: {
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      password: "welcome",
      confirm_password: "welcome"
    })
    assert_nil result.data.signup.user
    assert_not_empty result.data.signup.errors.flat_map(&:path) & ["signup", "email"]
  end

  test "signup when passwords do no match" do
    result = AceHelp::Client.execute(@signup_mutation, input: {
      first_name: "drake",
      last_name: "skywalker",
      email: "drake@example.com",
      password: "welcome",
      confirm_password: "wrlcome"
    })
    assert_nil result.data.signup.user
    assert_not_empty result.data.signup.errors.flat_map(&:path) & ["signup", "password"]
  end
end
