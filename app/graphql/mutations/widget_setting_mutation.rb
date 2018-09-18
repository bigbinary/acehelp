# frozen_string_literal: true

class Mutations::WidgetSettingMutation
  Create = GraphQL::Relay::Mutation.define do
    name "SaveSettings"

    input_field :base_url, types.String

    return_field :setting, Types::SettingType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      new_setting = Setting.new(
        organization_id: context[:organization].id,
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

    input_field :visibility, !types.String

    return_field :setting, Types::SettingType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      setting = Setting.find_or_create_by(organization_id: context[:organization].id)
      if setting
        if setting.update_attributes(visibility: inputs[:visibility])
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
