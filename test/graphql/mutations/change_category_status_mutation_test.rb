# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::ChangeCategoryStatusMutationsTest < ActiveSupport::TestCase
  setup do
    @category = categories :novel
    @query = <<-GRAPHQL
        mutation($input: ChangeCategoryStatusInput!) {
          changeCategoryStatus(input: $input) {
            category {
              id
              status
            }
            errors {
              path
              message
            }
          }
        }
    GRAPHQL
  end

  test "update category status with ONLINE" do
    result = AceHelp::Client.execute(@query, input: { id: @category.id, status: "online" })
    assert_equal Category.statuses[:online], result.data.change_category_status.category.status
  end

  test "update category status with OFFLINE" do
    result = AceHelp::Client.execute(@query, input: { id: @category.id, status: "offline" })
    assert_equal Category.statuses[:offline], result.data.change_category_status.category.status
  end

  test "update category with invalid status" do
    assert_raises (ArgumentError) do
      AceHelp::Client.execute(@query, input: { id: @category.id, status: "NON_EXIST_STATUS" })
    end
  end
end
