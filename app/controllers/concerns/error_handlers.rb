module Concerns::ErrorHandlers
  extend ::ActiveSupport::Concern

  def render_unauthorized(err)
    render json: json_body(err), status: :unauthorized
  end

  def render_unprocessable_entity(err)
    render json: json_body(err), status: :unprocessable_entity
  end

  def render_bad_request(err)
    render json: json_body(err), status: :bad_request
  end

  def render_not_found(err)
    render json: json_body(err), status: :not_found
  end

  def render_not_acceptable(err)
    render json: json_body(err), status: :not_acceptable
  end

  def render_forbidden(err)
    render json: json_body(err), status: :forbidden
  end

  def render_service_not_available(err)
    render json: json_body(err), status: :service_unavailable
  end

  def render_ok(msg)
    render json: json_body(msg), status: :ok
  end

  def render_no_content(msg)
    render json: json_body(msg), status: 204
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
