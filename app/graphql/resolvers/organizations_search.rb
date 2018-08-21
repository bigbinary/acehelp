# frozen_string_literal: true

class Resolvers::OrganizationsSearch < GraphQL::Function
  type Types::OrganizationType

  argument :api_key, types.String

  def call(obj, args, context)
    Organization.find_by(api_key: args[:api_key])
  end
end
