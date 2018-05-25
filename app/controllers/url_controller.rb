class UrlController < ApplicationController

  before_action :load_url, only: [:update, :destroy]
  
  def index
    urls = @organization.urls
    render json: urls, root: "urls", status: 200
  end

  def create
    Url.create!(url_creation_params)
    render json: { message: "Url created successfully" }, status: 200
  end

  def update
    @url.update!(url_params)
    render json: { message: "url updated successfully" }, status: 200
  end

  def destroy
    @url.destroy!
    render json: { message: "url deleted successfully" }, status: 200
  end

  private

  def load_url
    @url = Url.find_by!(id: params[:id], organization_id: @organization.id)
  end

  def url_params
    params.require(:url).permit(:url)
  end

  def url_creation_params
    url_params.merge!(organization_id: @organization.id)
  end
end
