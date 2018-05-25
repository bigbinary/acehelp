module LoadOrganization

    extend ActiveSupport::Concern

    included do
      before_action :load_organization
    end

    def load_organization
      raise AuthModule::Unauthorized.new "Unauthorized Request" if request.headers["api-key"].blank?
      @organization = organization_scope.find_by(api_key: request.headers["api-key"])
      raise AuthModule::InvalidToken.new "Token not Valid" unless @organization
    end

    def organization_scope
      Organization
    end

end
