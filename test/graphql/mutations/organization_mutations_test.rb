# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::OrganizationMutationsTest < ActiveSupport::TestCase
  setup do
    @brad_user = users(:brad)
    @common_org_query = <<-GRAPHQL
              mutation($input: CreateOrganizationInput!) {
                createOrganization(input: $input) {
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
  end

  test "create organization" do
    result = AceHelp::Client.execute(@common_org_query, input: {
      user_id: @brad_user.id,
      name: "Org Name",
      email: "org_general_email@gmail.com"
    })
    assert_equal result.data.create_organization.organization.name, "Org Name"
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
        user_id: @brad_user.id,
        email: "org_general_email@gmail.com"
      })
    end
  end
end
