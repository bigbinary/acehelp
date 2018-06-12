# frozen_string_literal: true

class Admin::ArticlesController < ApplicationController
  def index
    if current_user
      render
    else
      redirect_to new_user_session_path
    end
  end
end
