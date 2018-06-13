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
        GraphQL::ExecutionError.new("Invalid input: #{new_url.errors.full_messages.join(', ')}")
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
    return_field :errors, types.String

    resolve ->(object, inputs, context) {
      url = Url.find_by(id: inputs[:id], organization_id: context[:organization].id)
      return { errors: "Url not found" } if url.nil?

      if url.update_attributes(inputs[:url].to_h)
        { url: url }
      else
        GraphQL::ExecutionError.new("Invalid input: #{url.errors.full_messages.join(', ')}")
      end
    }
  end

  Destroy = GraphQL::Relay::Mutation.define do
    name "DestroyUrl"

    input_field :id, !types.ID

    return_field :deletedId, !types.ID
    return_field :errors, types.String

    resolve ->(_obj, inputs, context) {
      url = Url.find_by(id: inputs[:id], organization_id: context[:organization].id)
      return { errors: "Url not found" } if url.nil?

      url.destroy!

      { deletedId: inputs[:id] }
    }
  end
end
