# frozen_string_literal: true

ActionMailer::Base.perform_deliveries = Rails.application.secrets.mailer[:perform_deliveries]

ActionMailer::Base.default_url_options[:host] = Rails.application.secrets.host

ActionMailer::Base.delivery_method = Rails.application.secrets.mailer[:mailer_delivery_method].to_sym

ActionMailer::Base.smtp_settings = Rails.application.secrets.mailer[:smtp_settings].symbolize_keys
