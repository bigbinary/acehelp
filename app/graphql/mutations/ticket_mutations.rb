# frozen_string_literal: true

class Mutations::TicketMutations
  Create = GraphQL::Relay::Mutation.define do
    name "CreateTicket"

    input_field :name, types.String
    input_field :email, !types.String
    input_field :message, !types.String

    return_field :ticket, Types::TicketType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      new_ticket = Ticket.new(name: inputs[:name],
                              email: inputs[:email],
                              message: inputs[:message],
                              user_agent: context[:user_agent],
                              organization_id: context[:organization].id
                              )

      if new_ticket.save
        ticket = new_ticket
      else
        errors = Utils::ErrorHandler.new.detailed_error(new_ticket, context)
      end

      {
        ticket: ticket,
        errors: errors
      }
    }
  end

  Delete = GraphQL::Relay::Mutation.define do
    name "DeleteTicket"

    input_field :id, types.String

    return_field :ticket, Types::TicketType
    return_field :errors, types[Types::ErrorType]

    resolve ->(object, inputs, context) {
      ticket = Ticket.find_by!(id: inputs[:id])

      if ticket.soft_delete
        ticket = ticket
      else
        errors = Utils::ErrorHandler.new.detailed_error(ticket, context)
      end

      {
        ticket: ticket,
        errors: errors
      }
    }
  end
end
