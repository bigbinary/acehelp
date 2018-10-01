# frozen_string_literal: true

class Resolvers::OrganizationListSearch < GraphQL::Function
  type !types[Types::OrganizationType]

  def call(obj, args, context)
    user = context[:current_user]
    user.organizations
  end
end
