# frozen_string_literal: true

module Resolvers
  module Fields
    class FetchField
      def self.build(model:, type:)
        return_type = type
        GraphQL::Field.define do
          type(return_type)
          description("Find a #{model.name} by ID")
          argument(:id, !types.Int, "ID for Record")
          resolve ->(obj, args, context) {
            model.find_by(id: args["id"], organization_id: context[:organization].id)
          }
        end
      end
    end
  end
end
