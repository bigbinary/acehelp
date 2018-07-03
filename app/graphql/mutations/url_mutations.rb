# frozen_string_literal: true

class Mutations::UrlMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateUrl"

    input_field :url, !types.String

    return_field :url, Types::UrlType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      new_url = Url.new(url: inputs[:url])
      new_url.organization = context[:organization]

      if new_url.save
        url = new_url
      else
        errors = Utils::ErrorHandler.new.generate_detailed_error_hash(new_url, context)
      end

      {
        url: url,
        errors: errors
      }
    }
  end

  Update = GraphQL::Relay::Mutation.define do
    name "UpdateUrl"

    UrlInputObjectType = GraphQL::InputObjectType.define do
      name "UrlInput"
      input_field :url, !types.String
    end
    input_field :id, !types.ID
    input_field :url, !UrlInputObjectType

    return_field :url, Types::UrlType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      url = Url.find_by(id: inputs[:id], organization_id: context[:organization].id)
      if url.nil?
        errors = Utils::ErrorHandler.new.generate_error_hash('Url not found', context)
      else
        if url.update_attributes(inputs[:url].to_h)
          updated_url = url
        else
          errors = Utils::ErrorHandler.new.generate_detailed_error_hash(url, context)
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

    input_field :id, !types.ID

    return_field :deletedId, !types.ID
    return_field :errors, types[Types::ErrorType]

    resolve ->(_obj, inputs, context) {
      url = Url.find_by(id: inputs[:id], organization_id: context[:organization].id)
      if url.nil?
        errors = Utils::ErrorHandler.new.generate_error_hash('Url not found', context)
      else
        if url.destroy
          deleted_id = inputs[:id]
        else
          errors = Utils::ErrorHandler.new.generate_detailed_error_hash(url, context)
        end
      end

      {
        deletedId: deleted_id,
        errors: errors
      }
    }
  end
end
