# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ::Concerns::ErrorHandlers

  skip_before_action :verify_authenticity_token
  private

  def ensure_user_is_logged_in
    unless current_user
      redirect_to new_user_session_path
    end
  end
end
