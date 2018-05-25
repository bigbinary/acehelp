module ModelApiKeyConcern
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_api_key_assigned
  end

  private

    def ensure_api_key_assigned
      return if self.api_key.present?
      loop do
        self.api_key = SecureRandom.hex(10)
        break unless self.class.where(api_key: api_key).exists?
      end
    end
end