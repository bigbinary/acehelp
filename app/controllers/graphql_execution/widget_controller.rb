# frozen_string_literal: true

class GraphqlExecution::WidgetController < GraphqlExecution::BaseController
  skip_before_action :verify_authenticity_token
end
