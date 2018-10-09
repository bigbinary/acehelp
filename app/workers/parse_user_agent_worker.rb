# frozen_string_literal: true

class ParseUserAgentWorker
  include Sidekiq::Worker

  def perform(ticket, user_agent)
    if user_agent.present?
      parsed_device_info = ParseUserAgentService.new(user_agent).parse
      update(device_info: parsed_device_info)
    else
      update(device_info: nil)
    end
  end
end
