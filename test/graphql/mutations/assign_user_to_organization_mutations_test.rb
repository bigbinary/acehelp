# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::AssignUserToOrganizationMutationsTest < ActiveSupport::TestCase
  setup do
    @ethan = users(:hunt)
    @ethan.password = @ethan.password_confirmation = "SelfDestructIn5"
    @ethan.save
    @login_query = <<-GRAPHQL
      mutation($login_keys: LoginUserInput!) {
          loginUser(input: $login_keys) {
            user_with_token {
              authentication_token {
                client
                access_token
                uid
              }
            }
            errors {
              message
              path
            }
          }
      }
    GRAPHQL
    @query = <<-GRAPHQL
        mutation($user_keys: AssignUserToOrganizationInput!) {
            assign_user_to_organization(input: $user_keys) {
              user {
                id
                email
                first_name
                last_name
                organizations {
                  id
                }
              }
              errors {
                message
                path
              }
            }
        }
    GRAPHQL
    AceHelp::Client.execute(@login_query, login_keys: { email: @ethan.email, password: "SelfDestructIn5" })
  end


  test "assign organization" do
    result = AceHelp::Client.execute(@query, user_keys: { email: @ethan.email })
    assert result.data.assign_user_to_organization.user.organizations.any?
  end

  test "api should return correct user" do
    result = AceHelp::Client.execute(@query, user_keys: { email: @ethan.email })
    assert_equal @ethan.email, result.data.assign_user_to_organization.user.email
  end

  test "api should return new user" do
    new_email = "new_email+#{rand(1000)}@example.com"
    result =  AceHelp::Client.execute(@query, user_keys: { email: new_email })
    assert_equal new_email,  result.data.assign_user_to_organization.user.email
  end

  test "assign organization with name" do
    new_email_2 =
    result = AceHelp::Client.execute(@query, user_keys: { email: "new_email_2@example.com", firstName: "Sagar", lastName: "Alias Jackey" })
    assert_equal "Sagar",  result.data.assign_user_to_organization.user.first_name
    assert_equal "Alias Jackey",  result.data.assign_user_to_organization.user.last_name
  end
end
