# frozen_string_literal: true

class Mutations::WidgetSettingMutation
  Update = GraphQL::Relay::Mutation.define do
    name "UpdateSettings"

    input_field :base_url, !types.String

    return_field :setting, Types::SettingType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      setting = Setting.find_or_create_by(organization_id: context[:organization].id)
      if setting
        if setting.update_attributes!(base_url: inputs[:base_url])
          updated_settings = setting
        else
          errors = Utils::ErrorHandler.new.detailed_error(setting, context)
        end
      else
        errors = Utils::ErrorHandler.new.error("Setting not available.", context)
      end
      {
        setting: updated_settings,
        errors: errors
      }
    }
  end

  EnableDisableWidget = GraphQL::Relay::Mutation.define do
    name "EnableDisableWidget"

    input_field :visibility, !types.String

    return_field :setting, Types::SettingType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      setting = Setting.find_or_create_by(organization_id: context[:organization].id)
      if setting
        if setting.update_attributes(visibility: inputs[:visibility].to_sym)
          updated_settings = setting
        else
          errors = Utils::ErrorHandler.new.detailed_error(setting, context)
        end
      else
        errors = Utils::ErrorHandler.new.error("Setting not available.", context)
      end
      {
        setting: updated_settings,
        errors: errors
      }
    }
  end
end
