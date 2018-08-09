# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::AssignUserToOrganizationMutationsTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  setup do
    @ethan = users(:hunt)
    sign_in @ethan
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
