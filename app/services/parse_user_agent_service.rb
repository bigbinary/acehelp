# frozen_string_literal: true

class ParseUserAgentService

  attr_reader :user_agent, :browser

  def initialize(user_agent)
    @user_agent = user_agent
    @browser = Browser.new(user_agent)
  end

  def parse
    parsed_device_details = {
      browser: browser_data,
      platfrom: platform_data,
      device: device_data
    }
    parsed_device_details[:bot] = bot_data if browser.bot?

    parsed_device_details
  end

  private
    def browser_data
      {
        id: browser.id,
        name: browser.name,
        version: browser.full_version
      }
    end

    def platform_data
      {
        id: browser.platform.id,
        name: browser.platform.name
      }
    end

    def device_data
      {
        id: browser.device.id,
        name: browser.device.name,
      }
    end

    def bot_data
      {
        is_bot: browser.bot?,
        name: browser.bot.name,
        is_search_engine: browser.bot.search_engine?
      }
    end

end
