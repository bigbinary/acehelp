# frozen_string_literal: true

class Articles::AttachmentsController < ApplicationController
  before_action :ensure_user_is_logged_in
  include LoadOrganization
  before_action :load_article, only: :create

  def create
    attachments = @article.attachments.attach(
      io: attachment_params[:file],
      content_type: attachment_params[:content_type],
      filename: attachment_params[:filename]
    )

    response = { success: true, attachment_url: url_for(attachments.last) }

    render json: response, status: :created
  end

  private

    def attachment_params
      params.require(:attachment).permit(:file, :filename, :content_type)
    end

    def load_article
      @article = Article.find(params[:article_id])
    end
end
