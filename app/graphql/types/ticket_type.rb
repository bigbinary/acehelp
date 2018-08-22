# frozen_string_literal: true

Types::TicketType = GraphQL::ObjectType.define do
  name "Ticket"
  field :id, !types.String
  field :name, types.String
  field :email, !types.String
  field :message, !types.String
  field :status, !types.String

  field :agent, -> { Types::UserType }  do
    resolve -> (obj, args, context) { obj.agent }
  end

  field :statuses, -> { types[Types::TicketStatusesType] } do
    resolve ->(obj, args, context) { Ticket::statuses }
  end

  field :comments, -> { !types[Types::TicketCommentType] } do
    preload :comments
    resolve ->(obj, args, context) { obj.comments }
  end

  field :notes, -> { !types[Types::TicketNoteType] } do
    preload :notes
    resolve ->(obj, args, context) { obj.notes }
  end
end
