# frozen_string_literal: true

class Ticket < ApplicationRecord
  validates :email, :message, presence: true
  belongs_to :organization

  belongs_to :agent, required: false
  has_many :comments, dependent: :destroy

  scope :for_organization, ->(org) { where(organization: org) }

  def assign_agent(agent_id)
    return false if !Agent.exists?(id: agent_id)
    update_attributes(agent_id: agent_id)
  end

  def add_note(note_txt)
    update(note: note_txt)
  end
end
