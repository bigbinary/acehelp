# frozen_string_literal: true

class Mutations::UrlMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateUrl"

    input_field :url, !types.String

    return_field :url, Types::UrlType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      new_url = Url.new(url: inputs[:url])
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
    input_field :url, !types.String

    return_field :url, Types::UrlType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      url = Url.find_by(id: inputs[:id], organization_id: context[:organization].id)

      if url.nil?
        errors = Utils::ErrorHandler.new.error("Url not found", context)
      else
        if url.update_attributes(url: inputs[:url])
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
end
