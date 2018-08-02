# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::DismissUserMutationsTest < ActiveSupport::TestCase

  setup do
    @ethan = users(:hunt)
    @ethan.organization_id = organizations(:bigbinary).id
    @ethan.save
    @query = <<-GRAPHQL
        mutation($user_keys: DismissUserFromOrganizationInput!) {
            dismissUser(input: $user_keys) {
              status
              errors {
                message
                path
              }
            }
        }
    GRAPHQL
  end

  test "dismiss user from organization" do
    result = AceHelp::Client.execute(@query, user_keys: {email: @ethan.email})
    assert_equal true, result.data.dismiss_user.status
  end

  test "dismiss user from different organization" do
    result = AceHelp::CustomClient.call(organizations(:zindi).api_key).execute(@query, user_keys: {email: @ethan.email})
    assert_equal nil, result.data.dismiss_user.status
    assert_includes result.data.dismiss_user.errors.flat_map(&:message), "Authorization failure. User is not a part of this organization"
  end

  test "dismiss user not signed up" do
    result = AceHelp::Client.execute(@query, user_keys: {email: "random@email.com"})
    assert_equal nil, result.data.dismiss_user.status
    assert_includes result.data.dismiss_user.errors.flat_map(&:message), "User not found"
  end


end