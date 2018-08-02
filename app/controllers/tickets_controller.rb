# frozen_string_literal: true

class TicketsController < ApplicationController
  before_action :ensure_user_is_logged_in
  include LoadOrganization

  def index
    render
  end
end
