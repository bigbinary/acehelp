class Admin::OrganizationsController < ApplicationController
  before_action :ensure_user_is_logged_in

  def new
    render
  end

end
