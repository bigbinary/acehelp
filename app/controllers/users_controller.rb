# frozen_string_literal: true

class UsersController < ApplicationController
  def sign_in
    render
  end

  def sign_out
    session.clear
    session.delete(:uid)
  end
end
