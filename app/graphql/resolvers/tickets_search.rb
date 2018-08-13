# frozen_string_literal: true

class Resolvers::TicketsSearch < GraphQL::Function
  type !types[Types::TicketType]

  argument :id, types.String
  argument :status, types.String

  def call(obj, args, context)
    query = Ticket.for_organization(context[:organization])

    if args[:id].present?
      query = query.where(id: args[:id])
    end

    if args[:status].present?
      query = query.where(status: args[:status])
    end

    query
  end
end
