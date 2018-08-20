# frozen_string_literal: true

require "test_helper"
require "graphql/client_host"

class Mutations::ChangeTriggerStatusMutationsTest < ActiveSupport::TestCase
  setup do
    @trigger = triggers(:auto_update_user)
    @query = <<-GRAPHQL
        mutation($trigger_args: ChangeTriggerStatusInput!) {
          changeTriggerStatus(input: $trigger_args) {
            trigger {
              id
              active
            }
            errors {
              path
              message
            }
          }
        }
    GRAPHQL
  end

  test "activate trigger" do
    result = AceHelp::Client.execute(@query, trigger_args: { id: @trigger.id, active: true })
    assert result.data.change_trigger_status.trigger.active
  end

  test "deactivate trigger" do
    result = AceHelp::Client.execute(@query, trigger_args: { id: @trigger.id, active: false })
    assert_not result.data.change_trigger_status.trigger.active
  end
end
