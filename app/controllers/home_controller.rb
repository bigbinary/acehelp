# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    render
  end

  def new
    render
  end

  def getting_started
    render "/pages/aceinvoice/getting_started"
  end

  def integrations
    render "/pages/aceinvoice/integrations"
  end

  def pricing
    render "/pages/aceinvoice/pricing"
  end
end
