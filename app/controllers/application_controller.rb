class ApplicationController < ActionController::Base

  protect_from_forgery with: :null_session

  include ::Concerns::Errors
  include ::Concerns::ErrorHandlers

  include LoadOrganization

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
