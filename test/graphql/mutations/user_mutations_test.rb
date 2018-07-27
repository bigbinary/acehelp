# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::UserMutationsTest < ActiveSupport::TestCase
  setup do
    @general_query = <<-GRAPHQL
    mutation($input: CreateUserInput!) {
      addUser(input: $input) {
        user {
          id
          name
        }
        errors {
          message
          path
        }
      }
    }
    GRAPHQL

    @user_inputs = { email: "email@example.com",
     first_name: "John",
     last_name: "Travolta",
     password: "password",
     password_confirmation: "password"
    }
  end

  test "user registration" do
    query = <<-GRAPHQL
              mutation($input: CreateUserInput!) {
                addUser(input: $input) {
                  user {
                    id
                    name
                    email
                  }
                }
              }
    GRAPHQL

    result = AceHelp::Client.execute(query, input:
      { email: "email@example.com",
       first_name: "John",
       last_name: "Travolta",
       password: "password",
       password_confirmation: "password"
      })

    assert_equal result.data.add_user.user.name, "John Travolta"
  end

  test "user registeration with wrong password confirmation" do
    query = <<-GRAPHQL
              mutation($input: CreateUserInput!) {
                addUser(input: $input) {
                  user {
                    id
                    name
                  }
                  errors {
                    message
                    path
                  }
                }
              }
    GRAPHQL

    result = AceHelp::Client.execute(query, input: @user_inputs.merge(password_confirmation: "wrongpwd"))
    assert_not_empty result.data.add_user.errors.flat_map(&:path) & ["addUser", "password_confirmation"]
  end

  test "user registeration with existing email" do
    brad_user = users(:brad)

    result = AceHelp::Client.execute(@general_query, input: @user_inputs.merge(email: brad_user.email))
    assert_not_empty result.data.add_user.errors.flat_map(&:path) & ["addUser", "email"]
  end
end
