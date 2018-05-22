module Api::V1
  class BaseController < ActionController::Base
  	
    include ::Concerns::Errors
    include ::Concerns::ErrorHandlers
  end
end
