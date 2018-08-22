# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :agent, class_name: "User"
  belongs_to :ticket

  def self.add_note!(args)
    agent = Agent.find_by!(id: args[:agent_id])
    note = agent.notes.create!(
      ticket_id: args[:ticket_id],
      details: args[:details]
    )
    note
  end
end
