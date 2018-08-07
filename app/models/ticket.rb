# frozen_string_literal: true

class Ticket < ApplicationRecord
  validates :email, :message, presence: true
  belongs_to :organization

  belongs_to :agent, required: false
  has_many :comments, dependent: :destroy

  scope :for_organization, ->(org) { where(organization: org) }
  scope :all_closed, -> { where(status:  STATUSES[:closed]) }
  scope :all_resolved, -> { where(status:  STATUSES[:resolved]) }
  scope :all_resolved_before_n_days, -> (day_count) { all_resolved.where('resolved_at < ?', day_count.days.ago) }

  after_save :parse_user_agent, if: :saved_change_to_user_agent?
  after_save :mark_status_updates, if: :saved_change_to_status?

  STATUSES = {
    open: "open",
    pending_on_customer: 'pending_on_customer',
    resolved: 'resolved',
    closed: 'closed'

  }


  after_save :parse_user_agent, if: :saved_change_to_user_agent?

  def set_open!
    update status: STATUSES[:open]
  end

  def assign_agent(agent_id)
    return false if !Agent.exists?(id: agent_id)
    update_attributes(agent_id: agent_id)
  end

  def update_status(status_key)
    return false if status == status_key.to_s
    update(status: status_key)
  end

  def close_ticket!
    update(status: STATUSES[:closed])
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

    def mark_status_updates
      if saved_change_to_status?
        if status == STATUSES[:resolved]
          update_columns resolved_at: Time.current, closed_at: nil
        elsif status == STATUSES[:closed]
          update_columns resolved_at:  nil, closed_at: Time.current
        else
          update_columns resolved_at: nil, closed_at: nil
        end
      end
    end
end
