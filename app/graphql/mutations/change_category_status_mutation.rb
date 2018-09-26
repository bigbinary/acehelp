# frozen_string_literal: true

class Mutations::ChangeCategoryStatusMutation
  Perform = GraphQL::Relay::Mutation.define do
    name "ChangeCategoryStatus"

    input_field :status, !types.String
    input_field :id, !types.String

    return_field :categories, types[Types::CategoryType]
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      category = Category.find_by(id: inputs[:id])

      if category
        if category.update(status: inputs[:status].downcase)
          categories = Category.for_organization(context[:organization])
          category.articles.update_all(status: inputs[:status].downcase)
        end
      else
        errors = Utils::ErrorHandler.new.error("Category Not found", context)
      end

      {
        categories: categories,
        errors: errors
      }
    }
  end
end
