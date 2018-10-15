# frozen_string_literal: true

class AppUrlCarrier
  def self.app_url(request = nil)
    if ENV["HEROKU_APP_URL"].present?
      URI(ENV["HEROKU_APP_URL"])
    elsif ENV["HEROKU_APP_NAME"].present?
      URI("https://#{ENV['HEROKU_APP_NAME']}.herokuapp.com")
    elsif ENV["APP_URL"].present?
      URI(ENV["APP_URL"])
    elsif request.present?
      URI(request.base_url)
    else
      URI("http://localhost:3000")
    end
  end
end
