# frozen_string_literal: true

<<<<<<< HEAD:app/graphql/types/contact_type.rb
Types::ContactType = GraphQL::ObjectType.define do
  name "Contact"
  field :id, !types.String
=======
Types::TicketType = GraphQL::ObjectType.define do
  name "Ticket"
  field :id, !types.ID
>>>>>>> change addContact to addTicket:app/graphql/types/ticket_type.rb
  field :name, !types.String
  field :email, !types.String
  field :message, !types.String
end
