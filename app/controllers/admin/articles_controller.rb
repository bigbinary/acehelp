# frozen_string_literal: true

class Admin::ArticlesController < ApplicationController
  before_action :ensure_user_is_logged_in, :set_organization

  def index
    render
  end

  def new
    render
  end

  def show
    render
  end
end
