# frozen_string_literal: true

class Resolvers::TicketsSearch < GraphQL::Function
  type !types[Types::TicketType]

  argument :id, types.ID

  def call(obj, args, context)
    if args[:id].present?
      Ticket.where(id: args[:id]).for_organization(context[:organization])
    else
      # Ticket.for_organization(context[:organization])
      Ticket.all
    end
  end
end
