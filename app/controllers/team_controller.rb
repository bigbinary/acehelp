# frozen_string_literal: true

class TeamController < ApplicationController
  include LoadOrganization

  before_action :ensure_user_is_logged_in

  def index
    render
  end
end
