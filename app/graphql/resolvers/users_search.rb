# frozen_string_literal: true

class Resolvers::UsersSearch < GraphQL::Function
  type !types[Types::UserType]

  def call(obj, args, context)
    query = User.for_organization(
      context[:organization]
    )
    query
  end
end
