class UrlController < ApplicationController

  before_action :set_url, only: [:update, :destroy]
  
  def index
    urls = @organization.urls
    render json: urls, root: "urls", status: 200
  end

  def create
    url = Url.new(url_params)
    url[:organization_id] = @organization.id

    if url.save
      render json: {message: "Url created successfully"}, status: 200
    else
      render_bad_request url.errors.full_messages.join(',')
    end
  end

  def update
    @url.update!(url_params)
    render json: {message: "url updated successfully"}, status: 200
  end

  def destroy
    @url.destroy!
    render json: {message: "url deleted successfully"}, status: 200
  end

  private

  def set_url
    @url = Url.find_by!(id: params[:id], organization_id: @organization.id)
  end

  def url_params
    params.require(:url).permit(:url)
  end

end
