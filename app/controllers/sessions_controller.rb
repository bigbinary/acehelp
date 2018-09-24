# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  def destroy
    sign_out_and_redirect current_user
  end
end
