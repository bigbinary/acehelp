# frozen_string_literal: true

class Admin::ArticlesController < ApplicationController
  before_action :ensure_user_is_logged_in

  def index
    render
  end

  def new
    render
  end
end
