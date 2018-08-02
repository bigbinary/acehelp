# frozen_string_literal: true

class Mutations::CategoryMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateCategory"

    input_field :name, !types.String

    return_field :category, Types::CategoryType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      new_category = Category.new name: inputs[:name]
      new_category.organization = context[:organization]
      if new_category.save
        category = new_category
      else
        errors = Utils::ErrorHandler.new.detailed_error(new_category, context)
      end

      {
        category: category,
        errors: errors
      }
    }
  end

  Update = GraphQL::Relay::Mutation.define do
    name "UpdateCategory"

    input_field :id, !types.String
    CategoryInputObjectType = GraphQL::InputObjectType.define do
      name "CategoryInput"
      input_field :name, !types.String
    end
    input_field :category, !CategoryInputObjectType

    return_field :category, Types::CategoryType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      category = Category.find_by(id: inputs[:id], organization_id: context[:organization].id)

      if category.nil?
        errors = Utils::ErrorHandler.new.error("Category not found", context)
      else
        if category.update_attributes(inputs[:category].to_h)
          updated_category = category
        else
          errors = Utils::ErrorHandler.new.detailed_error(category, context)
        end

        {
          category: updated_category,
          errors: errors
        }
      end
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "DestroyCategory"

    input_field :id, !types.String

    return_field :deletedId, !types.String
    return_field :errors, types[Types::ErrorType]

    resolve ->(_obj, inputs, context) {
      category = Category.find_by(id: inputs[:id], organization_id: context[:organization].id)

      if category.blank?
        errors = Utils::ErrorHandler.new.error("Category not found", context)
      else
        if category.destroy
          deleted_id = inputs[:id]
        else
          errors = Utils::ErrorHandler.new.detailed_error(category, context)
        end
      end

      {
        deletedId: deleted_id,
        errors: errors
      }
    }
  end
end
