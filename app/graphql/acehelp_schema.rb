# frozen_string_literal: true

AcehelpSchema = GraphQL::Schema.define do
  mutation(Types::MutationType)
  query(Types::QueryType)

  use GraphQL::Batch
  enable_preloading

  max_depth(8)

end
