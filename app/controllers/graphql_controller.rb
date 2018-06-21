# frozen_string_literal: true

class GraphqlController < ApplicationController
  include LoadOrganization

  def execute
    result = AcehelpSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue => e
    show_error_in_development(e)
    graphql_error = Utils::ErrorHandler.generate_graphql_error_with_root(e.message, path: ['System Exception'])
    render json: graphql_error, status: 500
  end

  private

    def query
      params[:query]
    end

    def variables
      ensure_hash params[:variables]
    end

    def operation_name
      params[:operationName]
    end

    def context
      {
        organization: @organization
      }
    end

    def ensure_hash(ambiguous_param)
      case ambiguous_param
      when String
        if ambiguous_param.present?
          ensure_hash(JSON.parse(ambiguous_param))
        else
          {}
        end
      when Hash, ActionController::Parameters
        ambiguous_param
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
      end
    end

  private
  def show_error_in_development(e)
    if Rails.env.development?
      logger.error e.message
      logger.error e.backtrace.join("\n")
    end
  end
end
