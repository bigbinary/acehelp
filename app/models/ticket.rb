# frozen_string_literal: true

class Ticket < ApplicationRecord
  validates :email, :message, presence: true
  belongs_to :organization

  belongs_to :agent, required: false
  has_many :comments, dependent: :destroy

  scope :for_organization, ->(org) { where(organization: org) }

  after_save :parse_user_agent, if: :saved_change_to_user_agent?


  def assign_agent(agent_id)
    return false if !Agent.exists?(id: agent_id)
    update_attributes(agent_id: agent_id)
  end
  
  def add_note(note_txt)
    update(note: note_txt)
  end

  private
    def parse_user_agent
      if user_agent.present?
        parsed_device_info = ParseUserAgentService.new(user_agent).parse
        update(device_info: parsed_device_info)
      else
        update(device_info: nil)
      end
    end
    handle_asynchronously :parse_user_agent

end
