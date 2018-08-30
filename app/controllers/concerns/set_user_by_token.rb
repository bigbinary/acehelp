# frozen_string_literal: true

module SetUserByToken
  extend ActiveSupport::Concern

  def current_user
    access_token = request.headers["access_token"]
    uid = request.headers["uid"]
    return if access_token.nil?
    @user = User.find_by(email: uid)
    render_unauthorized(unathorized_error_message) && return if @user.blank?
  end

  private

    def unathorized_error_message
      "Unauthorized request: Missing or invalid UID and Access Token Key"
    end
end
