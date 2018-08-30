# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::ChangeCategoryStatusMutationsTest < ActiveSupport::TestCase
  setup do
    @category = categories :novel
    @query = <<-GRAPHQL
        mutation($input: ChangeCategoryStatusInput!) {
          changeCategoryStatus(input: $input) {
            categories {
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

  test "update category status with ACTIVE" do
    result = AceHelp::Client.execute(@query, input: { id: @category.id, status: "active" })
    @category.reload
    assert_equal Category.statuses[:active], @category.status
  end

  test "update category status with INACTIVE" do
    result = AceHelp::Client.execute(@query, input: { id: @category.id, status: "inactive" })
    @category.reload
    assert_equal Category.statuses[:inactive], @category.status
  end

  test "update category with invalid status" do
    assert_raises (ArgumentError) do
      AceHelp::Client.execute(@query, input: { id: @category.id, status: "NON_EXIST_STATUS" })
    end
  end
end
