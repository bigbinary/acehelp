# frozen_string_literal: true

class ArticlesController < ApplicationController
  before_action :ensure_user_is_logged_in
  include LoadOrganization

  def index
    render
  end
end
