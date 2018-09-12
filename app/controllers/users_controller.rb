# frozen_string_literal: true

class UsersController < ApplicationController
  def sign_in
    if warden.user.present?
      @resource = User.find_by!(email: warden.user["email"])
      organization = @resource.organizations.first
      redirect_to(organization_articles_path(organization.api_key)) && (return)
    end
  end

  def sign_out
    warden.logout
  end
end
