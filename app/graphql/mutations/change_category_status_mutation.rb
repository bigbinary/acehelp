# frozen_string_literal: true

class Mutations::ChangeCategoryStatusMutation
  Perform = GraphQL::Relay::Mutation.define do
    name "ChangeCategoryStatus"

    input_field :status, !types.String
    input_field :id, !types.String

    return_field :category, Types::CategoryType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {

      category = Category.find_by(id: inputs[:id])

      if category
        updated_category = category if category.update(status: inputs[:status])
      else
        errors = Utils::ErrorHandler.new.error("Category Not found", context)
      end

      {
        category: updated_category,
        errors: errors
      }
    }
  end
end
