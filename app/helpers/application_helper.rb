# frozen_string_literal: true

module ApplicationHelper
  def app_url
    if ENV["HEROKU_APP_URL"].present?
      ENV["HEROKU_APP_URL"]
    elsif ENV["HEROKU_APP_NAME"]
      "//" + ENV["HEROKU_APP_NAME"] + ".herokuapp.com/"
    else
      request.base_url + "/"
    end
  end
end
