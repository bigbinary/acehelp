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

  c1 = Category.create! name: "Getting Started"
  c1.articles.create! title: "How do I put JavaScript code in my website?", desc: "coming soon"
  c1.articles.create! title: "Will putting JavaScript code in my website will make my site slower?", desc: "coming soon"

  c2 = Category.create! name: "Integrations"
  c2.articles.create! title: "Do you provide integration with wordpress?", desc: "coming soon"
  c2.articles.create! title: "Do you provide integration for PHP applications?", desc: "coming soon"

  c3 = Category.create! name: "Pricing"
  c3.articles.create! title: "Do I need to put credit card to try it out?", desc: "coming soon"
  c3.articles.create! title: "Do you offer custom plan?", desc: "coming soon"
  c3.articles.create! title: "Do you offer discount on yearly plan?", desc: "coming soon"

  puts "sample data was added successfully"
end

