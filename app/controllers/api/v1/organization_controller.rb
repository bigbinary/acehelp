# frozen_string_literal: true

module Api
  module V1
    class OrganizationController < BaseController
      def data
        org = Organization.find(params[:organization_id])

        render json: { organization: org, articles: org.articles, urls: org.urls }
      end
    end
  end
end
