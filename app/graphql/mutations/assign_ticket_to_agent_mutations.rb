# frozen_string_literal: true

class Mutations::AssignTicketToAgentMutations
  Perform = GraphQL::Relay::Mutation.define do
    name "AssignTicketToAgent"

    input_field :ticket_id, !types.String
    input_field :agent_id, !types.String

    return_field :status, types.Boolean
    return_field :errors, types[Types::ErrorType]

    resolve -> (object, inputs, context) {

      ticket = Ticket.find_by(id: inputs[:ticket_id])
      agent = Agent.find_by(id: inputs[:agent_id])
      if ticket.nil?
        err_message = "Ticket not found"
      elsif agent.nil?
        err_message = "Agent not found"
      else
        status = ticket.assign_agent(agent.id)
      end

      {
        status: status,
        errors: err_message ? Utils::ErrorHandler.new.error(err_message, context) : []
      }
    }
  end
end
