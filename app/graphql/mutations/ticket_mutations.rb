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
                              organization_id: context[:organization].id
                              )

      if new_ticket.save
        ticket = new_ticket
      else
        errors = Utils::ErrorHandler.new.generate_detailed_error_hash(new_ticket, context)
      end

      {
        ticket: ticket,
        errors: errors
      }
    }
  end
end
