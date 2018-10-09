Sidekiq::Extensions.enable_delay!

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
  schedule_file = Rails.application.secrets.sidekiq_schedule_file

  if File.exists?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end
