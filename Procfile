web: bundle exec puma -C config/puma.rb
release: bundle exec rake db:migrate && bundle exec rake perform_on_every_deploy
worker: bundle exec sidekiq -C config/sidekiq.yml
