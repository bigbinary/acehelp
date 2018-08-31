# frozen_string_literal: true

module SetUserByToken
  extend ActiveSupport::Concern

  included do
    before_action :current_user
  end

  def current_user
    access_token = request.headers["HTTP_ACCESS_TOKEN"] || cookies.signed[:access_token]
    uid = request.headers["HTTP_UID"] || cookies.signed[:uid]
    @client_id = request.headers["HTTP_CLIENT"] || cookies.signed[:client]
    return unless access_token.present? && uid.present?
    set_cookies(access_token, uid)
    @resource = User.find_by(email: uid)
    render_unauthorized(unathorized_error_message) && return if @resource.blank? || !@resource.valid_token?(access_token, @client_id)
  end

  private

    def unathorized_error_message
      "Unauthorized request: Missing or invalid UID and Access Token Key"
    end

    def set_cookies(access_token, uid)
      cookies.signed[:uid] = uid
      cookies.signed[:client] = @client_id
      cookies.signed[:access_token] = access_token
    end
end
