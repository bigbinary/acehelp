# frozen_string_literal: true

class GraphqlExecution::DashboardController < GraphqlExecution::BaseController
  def create
    result = AcehelpSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue => e
    show_error_in_logs(e)
    graphql_error = Utils::ErrorHandler.new.generate_graphql_error_with_root(e.message, path: ["System Exception"])
    render json: graphql_error, status: 500
  end

  private

    def context
      super.merge(current_user: current_user)
    end
end
