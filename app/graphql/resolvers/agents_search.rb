# frozen_string_literal: true

class Resolvers::AgentsSearch < GraphQL::Function
  type !types[Types::UserType]

  def call(obj, args, context)
    query = Agent.for_organization(
      context[:organization]
    )
    query
  end
end
