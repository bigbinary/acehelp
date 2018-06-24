class Admin::CategoriesController < ApplicationController
  include SetOrganization
  include SetUrl

  before_action :ensure_user_is_logged_in

  def index
    render
  end

  def new
    render
  end
end
