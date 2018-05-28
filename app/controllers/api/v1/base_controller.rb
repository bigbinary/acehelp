module Api::V1
  class BaseController < ActionController::Base
    include ::Concerns::ErrorHandlers
  end
end
