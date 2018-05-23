class ArticleController < ApplicationController
  
  def index
    url = Url.find_by(url: params[:url])

    if url.present?
      render json: url.articles, root: "articles", status: 200
    else
      render_bad_request "Bad request"
    end
  end

end
