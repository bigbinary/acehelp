# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if current_user
      redirect_to admin_dashboard_index_path
    else
      render
    end
  end

  def getting_started
    render
  end

  def integrations
    render
  end

  def pricing
    render
  end
end
