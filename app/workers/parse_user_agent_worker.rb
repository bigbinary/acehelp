# frozen_string_literal: true

class ParseUserAgentWorker
  include Sidekiq::Worker

  def perform(ticket, user_agent)
    if user_agent.present?
      parsed_device_info = ParseUserAgentService.new(user_agent).parse
      ticket.update_attributes!(device_info: parsed_device_info)
    end
  end
end
