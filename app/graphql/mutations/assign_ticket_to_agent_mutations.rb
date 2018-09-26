# frozen_string_literal: true

class Mutations::AssignTicketToAgentMutations
  Perform = GraphQL::Relay::Mutation.define do
    name "AssignTicketToAgent"

    input_field :ticket_id, !types.String
    input_field :agent_id, !types.String

    return_field :status, types.Boolean
    return_field :ticket, Types::TicketType
    return_field :errors, types[Types::ErrorType]

    resolve -> (object, inputs, context) {
      raise GraphQL::ExecutionError, "Not logged in" unless context[:current_user]
      ticket = Ticket.find_by(id: inputs[:ticket_id], organization_id: context[:organization].id)
      agent = Agent.for_organization(context[:organization]).find_by(id: inputs[:agent_id])
      if ticket.nil?
        errors = Utils::ErrorHandler.new.error("Ticket Not found", context)
      elsif agent.nil?
        errors = Utils::ErrorHandler.new.error("Agent Not found", context)
      else
        status = ticket.assign_agent(agent.id)
        updated_ticket = ticket.reload
      end

      {
        status: status,
        ticket: updated_ticket,
        errors: errors
      }
    }
  end
end
