class ApplicationController < ActionController::Base

  protect_from_forgery with: :null_session

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

  private

  def load_organization
    raise AuthModule::Unauthorized.new "Unauthorized Request" if request.headers["api-key"].blank?
    @organization = organization_scope.find_by(api_key: request.headers["api-key"])
    raise AuthModule::InvalidToken.new "Token not Valid" unless @organization
  end

  def organization_scope
    Organization
  end

end
