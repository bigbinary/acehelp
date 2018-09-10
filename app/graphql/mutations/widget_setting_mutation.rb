# frozen_string_literal: true

class Mutations::WidgetSettingMutation
  Create = GraphQL::Relay::Mutation.define do
    name "SaveSettings"

    input_field :api_key, types.String
    input_field :app_url, types.String
    input_field :base_url, types.String

    return_field :setting, Types::SettingType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      setting = Setting.new(
        api_key: inputs[:api_key],
        app_url: inputs[:app_url],
        base_url: inputs[:base_url]
      )
      if new_setting.save
        setting = new_setting
      else
        errors = Utils::ErrorHandler.new.detailed_error(new_setting, context)
      end
      {
        setting: setting,
        errors: errors
      }
    }
  end

  EnableDisableWidget = GraphQL::Relay::Mutation.define do
    name "EnableDisableWidget"

    input_field :id, !types.String
    input_field :visibility, !types.String

    return_field :setting, Types::SettingType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      setting = Setting.find_by(id: inputs[:id], organization_id: context[:organization].id)
      if setting
        if setting.send(inputs[:visibility])
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
