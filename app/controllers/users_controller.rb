# frozen_string_literal: true

class UsersController < ApplicationController
  def sign_in
    render
  end

  def sign_out
    session.destroy
    cookies.delete :uid
    cookies.delete :access_token
    cookies.delete :client
  end
end
