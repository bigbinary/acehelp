# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if user_signed_in?
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

  def upload
    attachments = Article.first.files.attach(
      io: attachment_params[:file],
      filename: attachment_params[:filename],
      content_type: attachment_params[:content_type]
    )

    render json: { success: true, attachment_url: url_for(attachments.first) }, status: :created
  end

  private

    def attachment_params
      params.require(:attachment).permit(:file, :filename, :content_type)
    end
end
