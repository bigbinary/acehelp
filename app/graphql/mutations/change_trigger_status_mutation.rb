# frozen_string_literal: true

class Mutations::ChangeTriggerStatusMutation
  Perform = GraphQL::Relay::Mutation.define do
    name "ChangeTriggerStatus"

    input_field :id, !types.String
    input_field :active, !types.Boolean

    return_field :trigger, Types::TriggerType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      trigger = Trigger.find_by(id: inputs[:id])

      if trigger
        updated_trigger = trigger if trigger.update(active: inputs[:active])
      else
        errors = Utils::ErrorHandler.new.error("Trigger Not found", context)
      end

      {
        trigger: updated_trigger,
        errors: errors
      }
    }
  end
end
