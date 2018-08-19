# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true

  belongs_to :ticket


  def assign_agent_to_ticket(agent_id)
    ticket.assign_agent(agent_id) if ticket.agent_id.blank?
  end

  def self.add_comment(args)
    commenter = Agent.find_by(id: args[:user_id]) || User.find_by(id: args[:user_id])
    if commenter
      comment = commenter.comments.create!(ticket_id: args[:ticket_id], info: args[:info])
      comment.ticket&.open! if commenter.is_a?(User)
      comment
    end
  end
end
