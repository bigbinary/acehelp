# frozen_string_literal: true

class Mutations::AddNoteToTicketMutations
  Perform = GraphQL::Relay::Mutation.define do
    name "AddNote"

    AddNoteObjectType = GraphQL::InputObjectType.define do
      name "AddNoteArgs"
      input_field :ticket_id, !types.String
      input_field :agent_id, !types.String
      input_field :note, !types.String

    end

    input_field :ticket, !AddNoteObjectType

    return_field :status, !types.Boolean
    return_field :errors, types[Types::ErrorType]

    resolve -> (object, inputs, context) {
      ticket = Ticket.find_by(id: inputs[:ticket][:ticket_id], organization_id: context[:organization].id)
      agent = Agent.find_by(id: inputs[:ticket][:agent_id], organization_id: context[:organization].id)
      if ticket.nil?
        err_message = "Ticket not found"
      elsif agent.nil?
        err_message = "Agent not found"
      elsif ticket.agent_id != agent.id
        err_message = "You are not authorized to add note in this ticket"
      else
        status = ticket.add_note(inputs[:note])
      end
      {
        status: !!status,
        errors: err_message ? Utils::ErrorHandler.new.error(err_message, context) : []
      }
    }
  end
end
