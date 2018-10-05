# frozen_string_literal: true

require "test_helper"

class Articles::AttachmentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = users(:brad)
    sign_in(@user)
    @article = articles :ror
    @organization = organizations :bigbinary

    @article.organization = @organization
    @article.save
    @headers = { "api-key": @organization.api_key }
    @attachment = create_attachment
  end

  test "successfully create attachment for an article" do
    file = fixture_file_upload(Rails.root.join("public", "apple-touch-icon.png"), "image/png")
    assert_difference "@article.attachments.count" do
      post "/organizations/#{@organization.api_key}/articles/#{@article.id}/attachments", params: {
          article_id: @article.id,
          attachment: { file: file,
            filename: file.original_filename,
            content_type: file.content_type
          }
        }
    end
  end

  test "successfully delete attachment for an article" do
    assert_difference "@article.attachments.count", -1 do
      delete "/organizations/#{@organization.api_key}/articles/#{@article.id}/attachments/#{@attachment.id}"
    end
  end

  def create_attachment
    file = fixture_file_upload(Rails.root.join("public", "apple-touch-icon.png"), "image/png")
    @article.attachments.attach(
      io: file,
      content_type: file.content_type,
      filename: file.original_filename
    )
    @article.attachments.last
  end
end
