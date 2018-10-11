Sidekiq::Extensions.enable_delay!

Sidekiq.configure_server do |config|
  # Reference:
  # 1. https://github.com/mperham/sidekiq/wiki/Using-Redis#complete-control
  # 2. https://elements.heroku.com/addons/redistogo, Max connection 10
  config.redis = { url: ENV['REDIS_URL'], size: 9 }
  schedule_file = Rails.application.secrets.sidekiq_schedule_file

  if File.exists?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'], size: 1 }
end
