module LoadOrganization

    extend ActiveSupport::Concern

    included do
      before_action :load_organization
    end

    def load_organization
      render_bad_request "Api key can not be blank" and return if request.headers["api-key"].blank?
      @organization = organization_scope.find_by(api_key: request.headers["api-key"])
      render_bad_request "Token not Valid" and return unless @organization
    end

    def organization_scope
      Organization
    end

end
