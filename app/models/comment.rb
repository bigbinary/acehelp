class Comment < ApplicationRecord

  belongs_to :agent
  belongs_to :ticket


  def assign_agent_to_ticket(agent_id)
    ticket.assign_agent(agent_id) if ticket.agent_id.blank?
  end

end
