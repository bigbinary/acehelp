# frozen_string_literal: true

class CategoriesController < ApplicationController
  include LoadOrganization

  before_action :ensure_user_is_logged_in

  def index
    render
  end

  def new
    render
  end
end
