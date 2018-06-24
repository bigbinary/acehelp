# frozen_string_literal: true

# This temporary, remove this concern once mapping between user and organization is created
module SetOrganization
  extend ActiveSupport::Concern

  included do
    before_action :set_organization
  end

  def set_organization
    @organization = Organization.first
  end
end