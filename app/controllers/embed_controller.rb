class EmbedController < ApplicationController
  def index
    @api_key = params[:api_key]
    @organization = Organization.find_by(api_key: @api_key)

    unless @api_key.present? && @organization.present?
      render_bad_request "parameters are missing or invalid"
    end
  end
end
