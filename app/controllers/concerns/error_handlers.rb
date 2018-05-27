module Concerns::ErrorHandlers
  extend ::ActiveSupport::Concern

  def render_unauthorized(err)
    render json: json_body(err), status: :unauthorized
  end

  def render_bad_request(err)
    render json: json_body(err), status: :bad_request
  end

  private

  #
  # Create json meta body for given message
  # @param message [String] Error Message
  #
  # @return [Hash] Meta Body
  def json_body(message)
    { errors: message }
  end
end
