# frozen_string_literal: true

desc "Ensure that code is not running in production environment"
task :not_production do
  if Rails.env.production? && ENV["DELETE_PRODUCTION_DATA"].blank?
    puts ""
    puts "*" * 50
    puts "Deleting production data is not allowed. "
    puts "If you really want to delete all production data and populate sample data then "
    puts "you can execute following command."
    puts "DELETE_PRODUCTION_DATA=1 rake setup_sample_data"
    puts " "
    puts "If you are using heroku then execute command as shown below"
    puts "heroku run rake setup_sample_data DELETE_PRODUCTION_DATA=1 -a app_name"
    puts "*" * 50
    puts ""
    throw :error
  end
end

desc "Sets up the project by running migration and populating sample data"
task setup: [:environment, :not_production, "db:drop", "db:create", "db:migrate"] do
  ["setup_sample_data"].each { |cmd| system "rake #{cmd}" }
end

def delete_all_records_from_all_tables
  ActiveRecord::Base.connection.schema_cache.clear!

  Dir.glob(Rails.root + "app/models/*.rb").each { |file| require file }

  ApplicationRecord.descendants.each do |klass|
    klass.reset_column_information
    klass.delete_all
  end
end

desc "Deletes all records and populates sample data"
task setup_sample_data: [:environment] do
  delete_all_records_from_all_tables
  system "rake db:seed"

  create_user

  puts "sample data was added successfully"
end

def create_user(options = {})
  user_attributes = { email: "sam@example.com",
                      first_name: "Sam",
                      last_name: "Smith",
                      password: "welcome" }
  attributes = user_attributes.merge(options)

  User.create! attributes

  create_sample_data
end

def create_sample_data
  org1 = Organization.create! name: "AceInvoice", email: "aceinvoice@example.com"
  org2 = Organization.create! name: "EventsInIndia", email: "eventsinindia@example.com"

  u1 = org1.urls.create! url: "http://aceinvoice.com/getting-started"
  u2 = org1.urls.create! url: "http://aceinvoice.com/integrations"
  u3 = org1.urls.create! url: "http://aceinvoice.com/pricing"

  u5 = org2.urls.create! url: "http://healthcity.com/getting-started"
  u6 = org2.urls.create! url: "http://healthcity.com/integrations"
  u7 = org2.urls.create! url: "http://healthcity.com/pricing"

  c1 = Category.create! name: "Getting Started"
  a1 = c1.articles.create! title: "How do I put JavaScript code in my website?", desc: "coming soon", organization_id: org1.id
  a2 = c1.articles.create! title: "Will putting JavaScript code in my website will make my site slower?", desc: "coming soon", organization_id: org2.id

  c2 = Category.create! name: "Integrations"
  a3 = c2.articles.create! title: "Do you provide integration with wordpress?", desc: "coming soon", organization_id: org1.id
  a4 = c2.articles.create! title: "Do you provide integration for PHP applications?", desc: "coming soon", organization_id: org2.id

  c3 = Category.create! name: "Pricing"
  a5 = c3.articles.create! title: "Do I need to put credit card to try it out?", desc: "coming soon", organization_id: org1.id
  a6 = c3.articles.create! title: "Do you offer custom plan?", desc: "coming soon", organization_id: org2.id
  a7 = c3.articles.create! title: "Do you offer discount on yearly plan?", desc: "coming soon", organization_id: org1.id

  ArticleUrl.create! article_id: a1.id, url_id: u1.id
  ArticleUrl.create! article_id: a3.id, url_id: u1.id
  ArticleUrl.create! article_id: a1.id, url_id: u3.id
  ArticleUrl.create! article_id: a3.id, url_id: u2.id
  ArticleUrl.create! article_id: a5.id, url_id: u2.id
  ArticleUrl.create! article_id: a7.id, url_id: u1.id

  ArticleUrl.create! article_id: a2.id, url_id: u5.id
  ArticleUrl.create! article_id: a4.id, url_id: u5.id
  ArticleUrl.create! article_id: a6.id, url_id: u6.id
  ArticleUrl.create! article_id: a2.id, url_id: u7.id
  ArticleUrl.create! article_id: a4.id, url_id: u6.id
  ArticleUrl.create! article_id: a6.id, url_id: u7.id


end
