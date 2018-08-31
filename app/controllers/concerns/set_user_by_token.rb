# frozen_string_literal: true

module SetUserByToken
  extend ActiveSupport::Concern

  included do
    before_action :current_user
  end

  def current_user
    access_token = request.headers["HTTP_ACCESS_TOKEN"]
    uid = request.headers["HTTP_UID"]
    @client_id = request.headers["HTTP_CLIENT"] || "default"
    return if access_token.nil? && uid.nil?
    @resource = User.find_by(email: uid)
    render_unauthorized(unathorized_error_message) && return if @resource.blank? || !@resource.valid_token?(access_token, @client_id)
  end

  private

    def unathorized_error_message
      "Unauthorized request: Missing or invalid UID and Access Token Key"
    end
end
