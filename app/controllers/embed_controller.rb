class EmbedController < ApplicationController
  def index
    @api_key = params[:api_key]
    @organization = Organization.find_by(api_key: @api_key)

    unless @api_key.present? && @organization.present?
      render_bad_request "Api key is missing. Please provide in api_key parameter."
    end
  end
end
