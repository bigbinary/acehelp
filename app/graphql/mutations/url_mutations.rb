# frozen_string_literal: true

class Mutations::UrlMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateUrl"

    input_field :url, !types.String

    return_field :url, Types::UrlType

    resolve ->(object, inputs, context) {
      new_url = Url.new(url: inputs[:url])
      new_url.organization = context[:organization]

      if new_url.save
        { url: new_url }
      else
        raise GraphQL::ExecutionError.new(Utils::ErrorHandler.new.object_error_full_messages(new_url))
      end
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

    resolve ->(object, inputs, context) {
      url = Url.find_by(id: inputs[:id], organization_id: context[:organization].id)
      if url.nil?
        raise GraphQL::ExecutionError.new("Url not found")
      else
        if url.update_attributes(inputs[:url].to_h)
          { url: url }
        else
          raise GraphQL::ExecutionError.new(Utils::ErrorHandler.new.object_error_full_messages(url))
        end
      end
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "DestroyUrl"

    input_field :id, !types.ID

    return_field :deletedId, !types.ID

    resolve ->(_obj, inputs, context) {
      url = Url.find_by(id: inputs[:id], organization_id: context[:organization].id)
      if url.nil?
        raise GraphQL::ExecutionError.new("Url not found")
      else
        if url.destroy
          { deletedId: inputs[:id] }
        else
          raise GraphQL::ExecutionError.new(Utils::ErrorHandler.new.object_error_full_messages(url))
        end
      end
    }
  end
end
