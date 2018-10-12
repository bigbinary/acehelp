# frozen_string_literal: true

class GraphqlExecution::WidgetController < GraphqlExecution::BaseController
  skip_before_action :verify_authenticity_token

  private

    def context
      super.merge(request_source: Utils::Constants::REQUEST_SOURCE_WIDGET)
    end
end
