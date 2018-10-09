# frozen_string_literal: true

class Mutations::UrlMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateUrl"

    input_field :url_rule, !types.String
    input_field :url_pattern, !types.String

    return_field :url, Types::UrlType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      new_url = Url.new(url_rule: inputs[:url_rule], url_pattern: inputs[:url_pattern])
      new_url.organization = context[:organization]

      if new_url.save
        url = new_url
      else
        errors = Utils::ErrorHandler.new.detailed_error(new_url, context)
      end

      {
        url: url,
        errors: errors
      }
    }
  end

  Update = GraphQL::Relay::Mutation.define do
    name "UpdateUrl"

    input_field :id, !types.String
    input_field :url_pattern, !types.String
    input_field :url_rule, types.String

    return_field :url, Types::UrlType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      url = Url.find_by(id: inputs[:id], organization_id: context[:organization].id)

      if url.nil?
        errors = Utils::ErrorHandler.new.error("Url not found", context)
      else
        if url.update_attributes(
          url_rule: inputs[:url_rule],
          url_pattern: inputs[:url_pattern]
        )
          updated_url = url
        else
          errors = Utils::ErrorHandler.new.detailed_error(url, context)
        end
      end

      {
        url: updated_url,
        errors: errors
      }
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "DestroyUrl"

    input_field :id, !types.String

    return_field :deletedId, !types.String
    return_field :errors, types[Types::ErrorType]

    resolve ->(_obj, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      url = Url.find_by(id: inputs[:id], organization_id: context[:organization].id)
      if url.nil?
        errors = Utils::ErrorHandler.new.error("Url not found", context)
      else
        if url.destroy
          deleted_id = inputs[:id]
        else
          errors = Utils::ErrorHandler.new.detailed_error(url, context)
        end
      end

      {
        deletedId: deleted_id,
        errors: errors
      }
    }
  end

  AssignCategoryToUrlPattern = GraphQL::Relay::Mutation.define do
    name "AssignCategoryToUrlPattern"

    input_field :id, !types.String
    input_field :category_ids, types[types.String]

    return_field :url, Types::UrlType
    return_field :errors, types[Types::ErrorType]

    resolve ->(_obj, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      url = Url.find_by(id: inputs[:id], organization_id: context[:organization].id)
      if url.nil?
        errors = Utils::ErrorHandler.new.error("Url not found", context)
      else
        if inputs[:category_ids].empty?
          url.url_categories.delete_all
        else
          categories = Category.where(id: inputs[:category_ids])
          if categories.any?
            url.categories << categories
            updated_url = url
          else
            errors = Utils::ErrorHandler.new.error("Categories not present.", context)
          end
        end
      end
      {
        url: updated_url,
        errors: errors
      }
    }
  end
end
