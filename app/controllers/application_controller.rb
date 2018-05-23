class ApplicationController < ActionController::Base

  include ::Concerns::Errors
  include ::Concerns::ErrorHandlers

  def index
    render
  end

  def getting_started
    render
  end

  def integrations
    render
  end

  def pricing
    render
  end

end
