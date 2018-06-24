# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  include SetOrganization
  include SetUrl

  before_action :ensure_user_is_logged_in

  def index
    render
  end
end
