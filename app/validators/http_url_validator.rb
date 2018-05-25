class HttpUrlValidator < ActiveModel::Validator

  def self.compliant?(value)
    uri = URI.parse(value)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  def validate(record)
    unless record.url.present? && self.class.compliant?(record.url)
      record.errors.add("Url", "is not a valid HTTP URL")
    end
  end

end