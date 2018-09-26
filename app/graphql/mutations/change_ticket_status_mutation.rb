# frozen_string_literal: true

class Mutations::ChangeTicketStatusMutation
  Perform = GraphQL::Relay::Mutation.define do
    name "ChangeTicketStatus"

    input_field :status, !types.String
    input_field :id, !types.String

    return_field :ticket, Types::TicketType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      ticket = Ticket.find_by(id: inputs[:id])

      if ticket
        updated_ticket = ticket if ticket.update(status: inputs[:status])
      else
        errors = Utils::ErrorHandler.new.error("Ticket Not found", context)
      end

      {
        ticket: updated_ticket,
        errors: errors
      }
    }
  end
end
