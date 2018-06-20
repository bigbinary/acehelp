# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ::Concerns::ErrorHandlers

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def ensure_user_is_logged_in
    unless current_user
      redirect_to new_user_session_path
    end
  end
end
