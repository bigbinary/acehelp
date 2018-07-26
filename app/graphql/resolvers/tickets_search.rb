# frozen_string_literal: true

class Resolvers::TicketsSearch < GraphQL::Function
  type !types[Types::TicketType]

  argument :id, types.String

  def call(obj, args, context)
    query = Ticket.for_organization(context[:organization])

    args[:id].present? ? query.where(id: args[:id]) : query
  end
end
