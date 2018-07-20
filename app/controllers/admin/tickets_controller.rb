# frozen_string_literal: true

class Admin::TicketsController < ApplicationController
  before_action :ensure_user_is_logged_in, :set_organization

  def index
    render
  end
end
