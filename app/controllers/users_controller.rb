# frozen_string_literal: true

class UsersController < ApplicationController
  def sign_in
  end

  def sign_out
    session.destroy
    cookies.delete :uid
  end
end
