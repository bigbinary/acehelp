# frozen_string_literal: true

class Ticket < ApplicationRecord
  validates :email, :message, presence: true
  belongs_to :organization

  belongs_to :agent, required: false

  scope :for_organization, ->(org) { where(organization: org) }

  def assign_agent(agent_id)
    return false if !Agent.exists?(id: agent_id)
    update_attributes(agent_id: agent_id)
  end
end
