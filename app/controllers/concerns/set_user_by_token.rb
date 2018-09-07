# frozen_string_literal: true

module SetUserByToken
  extend ActiveSupport::Concern

  included do
    before_action :set_auth_token_cookies
  end

  def set_auth_token_cookies
    @_current_user ||= current_user
  end

  def current_user
    access_token = cookies.signed[:access_token]
    uid = cookies.signed[:uid]
    @client_id = cookies.signed[:client]
    return unless access_token.present? && uid.present?

    set_cookies(access_token, @client_id, uid)
    set_resource(uid)
    if @resource.blank? || !@resource.valid_token?(access_token, @client_id)
      render_unauthorized(unathorized_error_message) && return
    end
  end

  def set_cookies_after_successful_login(result)
    return unless result["data"] && result["data"]["loginUser"] && result["data"]["loginUser"]["user_with_token"]
    token = result["data"]["loginUser"]["user_with_token"]["authentication_token"]
    if token.present?
      logger.info("================Token setup for login mutation : #{token["uid"]}=============")
      set_cookies(token["access_token"], token["client"], token["uid"])
      set_resource(token["uid"])
    end
  end

  def update_cookies_after_every_result(auth_header)
    set_cookies(auth_header["access-token"], auth_header["client"], auth_header["uid"])
    logger.info("================ auth_header setup : #{auth_header["uid"]} =============")
    set_resource(auth_header["uid"])
  end

  def set_resource(uid)
    @resource = User.find_by(email: uid)
 end

  private

    def unathorized_error_message
      "Unauthorized request: Missing or invalid UID and Access Token Key"
    end

    def set_cookies(access_token, client_id, uid)
      cookies.signed[:uid] = uid
      cookies.signed[:client] = client_id
      cookies.signed[:access_token] = access_token
    end
end
