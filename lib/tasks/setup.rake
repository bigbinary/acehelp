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

  create_user!
  create_org_info!

  puts "sample data was added successfully"
end

def create_org_info!
  organization = Organization.create!(name: "CareForever")

  getting_started = organization.categories.create! name: "Getting Started"
  user_permissions_and_access_control = organization.categories.create! name: "User Permissions and Access Control"
  care_plan = organization.categories.create! name: "CarePlan"

  article1 = Article.create! name: "How do I add a new Care Recipient?",
                             organization: organization, category: getting_started
  article2 = Article.create! name: "How do users I invite to join CareGeneral set up their account the first time?",
                             organization: organization, category: user_permissions_and_access_control
  article3 = Article.create! name: "How do I create a task?",
                            organization: organization, category: care_plan
end

def create_user!(options = {})
  user_attributes = { email: "sam@example.com",
                      first_name: "Sam",
                      last_name: "Smith",
                      password: "welcome" }
  attributes = user_attributes.merge(options)

  User.create! attributes
end
