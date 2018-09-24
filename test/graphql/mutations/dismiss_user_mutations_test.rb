# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::DismissUserMutationsTest < ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  setup do
    @ethan = users(:hunt)
    @ethan.organization_id = organizations(:bigbinary).id
    @ethan.save
    sign_in @ethan
    @query = <<-GRAPHQL
        mutation($user_keys: DismissUserFromOrganizationInput!) {
            dismissUser(input: $user_keys) {
              status
              team {
                id
                name
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

  test "dismiss user from organization" do
    result = AceHelp::Client.execute(@query, user_keys: { email: @ethan.email })
    assert_not_nil true, result.data.dismiss_user.team
  end


  test "dismiss user from different organization" do
    result = AceHelp::CustomClient.call(organizations(:zindi).api_key).execute(@query, user_keys: { email: @ethan.email })
    assert_nil result.data.dismiss_user.status
    assert_includes result.data.dismiss_user.errors.flat_map(&:message), "This user is not part of any organization"
  end

  test "dismiss user not signed up" do
    result = AceHelp::Client.execute(@query, user_keys: { email: "random@email.com" })
    assert_nil result.data.dismiss_user.status
    assert_includes result.data.dismiss_user.errors.flat_map(&:message), "User not found"
  end
end
