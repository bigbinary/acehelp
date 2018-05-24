module Concerns::Errors
  extend ::ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordNotSaved, with: :render_unprocessable_entity
    rescue_from BadRequest, with: :render_bad_request
    rescue_from AuthModule::InvalidToken, with: :render_unauthorized
    rescue_from AuthModule::Unauthorized, with: :render_unauthorized
  end
end
