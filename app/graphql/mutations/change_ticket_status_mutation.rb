# frozen_string_literal: true

class Mutations::ChangeTicketStatusMutation
  Perform = GraphQL::Relay::Mutation.define do
    name "ChangeTicketStatus"

    input_field :status, !Types::TicketStatusEnumType
    input_field :ticket_id, !types.String

    return_field :updated_ticket, !types.Boolean
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {

      ticket = Ticket.find_by(id: inputs[:ticket_id])

      if ticket
        updated_ticket = ticket.update_attributes(status: inputs[:status])
      else
        errors = Utils::ErrorHandler.new.error("Ticket Not found", context)
      end

      {
        updated_ticket: updated_ticket,
        errors: errors
      }
    }
  end
end
