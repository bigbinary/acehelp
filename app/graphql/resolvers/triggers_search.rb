# frozen_string_literal: true

class Resolvers::TriggersSearch < GraphQL::Function
  type !types[Types::TriggerType]


  def call(obj, args, context)
    query = Trigger.all
    query
  end

end
