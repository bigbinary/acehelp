# frozen_string_literal: true

Types::UrlType = GraphQL::ObjectType.define do
  name "Url"
  field :id, !types.String
  field :url_rule, !types.String
  field :url_pattern, -> { !types.String } do
    resolve ->(obj, args, context) {
      obj.change_url_pattern_to_placeholder
    }
  end
end
