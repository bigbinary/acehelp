# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::OrganizationMutationsTest < ActiveSupport::TestCase
  setup do
    @user = users(:brad)
    @user.password = @user.password_confirmation = "SelfDestructIn5"
    @user.save
    login_query = <<-GRAPHQL
      mutation($login_keys: LoginUserInput!) {
        loginUser(input: $login_keys) {
          user {
            id
          }
          errors {
            message
            path
          }
        }
      }
    GRAPHQL
    @common_org_query = <<-GRAPHQL
              mutation($input: CreateOrganizationInput!) {
                addOrganization(input: $input) {
                  organization {
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
    AceHelp::Client.execute(login_query, login_keys: { email: @user.email, password: "SelfDestructIn5" })
  end

  test "create organization" do
    result = AceHelp::Client.execute(@common_org_query, input: {
      user_id: @user.id,
      name: "Org Name",
      email: "org_general_email@gmail.com"
    })
    assert_equal result.data.add_organization.organization.name, "Org Name"
  end

  test "create organization without user_id" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@common_org_query, input: {
        name: "Org Name",
        email: "org_general_email@gmail.com"
      })
    end
  end

  test "create organization without name" do
    assert_raise(Graphlient::Errors::GraphQLError) do
      AceHelp::Client.execute(@common_org_query, input: {
        user_id: @user.id,
        email: "org_general_email@gmail.com"
      })
    end
  end

  test "default settings are created after an organization is created" do
    result = AceHelp::Client.execute(@common_org_query, input: {
      user_id: @user.id,
      name: "New Organisation Name",
      email: "org_general_email@gmail.com"
    })
    organization_id = result.data.add_organization.organization.id
    organization = Organization.find_by!(id: organization_id)

    assert organization.setting
  end
end
