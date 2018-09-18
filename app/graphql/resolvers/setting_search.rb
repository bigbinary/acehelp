# frozen_string_literal: true

class Resolvers::SettingSearch < GraphQL::Function
  type !Types::SettingType

  def call(obj, args, context)
    Setting.find_by(organization_id: context[:organization].id)
  end
end
