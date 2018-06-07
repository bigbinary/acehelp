module UserRoleConcern
  extend ActiveSupport::Concern

  def set_roles(roles, options = {})
    after_initialize do
      self.role ||= options[:default] if options[:default]
    end

    define_singleton_method 'all_roles' do
      roles
    end

    roles.each do |role|
      scope "#{role}_role".to_sym, -> { where(role: role) }

      define_method "set_#{role}_role!" do
        self.update!(role: role)
      end

      define_method "is_#{role}?" do
        self.role == role
      end
    end
  end
end
