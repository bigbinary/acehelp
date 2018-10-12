# frozen_string_literal: true

class Ticket < ApplicationRecord
  include Deletable

  enum status: {
    open: "open",
    pending_on_customer: "pending_on_customer",
    resolved: "resolved",
    closed: "closed"
  }

  enum priority: { low: "low", medium: "medium", high: "high", urgent: "urgent" }

  validates :email, :message, presence: true
  belongs_to :organization

  belongs_to :agent, required: false
  has_many :comments, dependent: :destroy
  has_many :notes, dependent: :destroy

  scope :for_organization, ->(org) { where(organization: org) }
  scope :all_resolved_before_n_days, -> (day_count) { resolved.where("resolved_at < ?", day_count.days.ago) }

  after_save :parse_user_agent, if: :saved_change_to_user_agent?
  after_save :mark_status_updates, if: :saved_change_to_status?

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

  private
    def parse_user_agent
      ParseUserAgentWorker.perform_async(self, user_agent)
    end

    def mark_status_updates
      if saved_change_to_status?
        if resolved?
          update_columns resolved_at: Time.current, closed_at: nil
        elsif closed?
          update_columns resolved_at:  nil, closed_at: Time.current
        else
          update_columns resolved_at: nil, closed_at: nil
        end
      end
    end
end
