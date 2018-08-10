Types::TokenType = GraphQL::ObjectType.define do
  name "Token"

  field :access_token, -> { types.String } do
    resolve -> (obj, args, context) { obj["access-token"] }
  end

  field :token_type, -> { types.String } do
    resolve -> (obj, args, context) { obj["token-type"] }
  end

  field :client, -> { types.String } do
    resolve -> (obj, args, context) { obj["client"] }
  end

  field :expiry, -> { types.String } do
    resolve -> (obj, args, context) { obj["expiry"] }
  end

  field :uid, -> { types.String } do
    resolve -> (obj, args, context) { obj["uid"] }
  end
end

