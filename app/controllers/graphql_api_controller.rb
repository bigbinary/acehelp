# frozen_string_literal: true

class GraphqlApiController < ApplicationController
  include LoadOrganization
  skip_before_action :verify_authenticity_token

  def execute
    result = AcehelpSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue => e
    show_error_in_logs(e)
    graphql_error = Utils::ErrorHandler.new.generate_graphql_error_with_root(e.message, path: ["System Exception"])
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
      context = {}
      context[:organization] = @organization if @organization.present?
      context[:request] = request
      context
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

    def render_unauthorized(message)
      render json: Utils::ErrorHandler.new.generate_graphql_error_with_root(message,
                                                                            path: "load_organization",
                                                                            extensions: { code: "UNAUTHORIZED" })
    end

    def show_error_in_logs(e)
      logger.error e.message
      logger.error e.backtrace.join("\n")

      raise e if Rails.env.test?
    end

    def request_is_mutation?
      params[:query].starts_with?("mutation")
    end

    def request_is_mutation_for?(mutation_type)
      request_is_mutation? && params[:query] =~ /#{mutation_type}/
    end
end
