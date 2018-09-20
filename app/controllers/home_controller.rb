# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if current_user.present?
      if current_user.organizations.empty?
        redirect_to new_organization_path
      else
        organization = current_user.organizations.first
        redirect_to organization_articles_path(organization.api_key)
      end
    end
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
