# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::Base
      include ::Concerns::ErrorHandlers
    end
  end
end
