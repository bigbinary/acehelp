# frozen_string_literal: true

class Resolvers::OrganizationsSearch < GraphQL::Function
  type Types::OrganizationType

  def call(obj, args, context)
    Organization.find_by(api_key: context[:organization].api_key)
  end
end
