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
  ["perform_on_every_deploy"].each { |cmd| system "rake #{cmd}" }
end

desc "Deletes all records and populates sample data"
task setup_sample_data: [:environment] do
  delete_all_records_from_all_tables

  create_user

  puts "sample data was added successfully"
end

desc "Perform steps required for every deployment"
task perform_on_every_deploy: [:environment, :not_production, "disable_searchkick_callbacks", "setup_sample_data", "reindex_searchkick"] do
end

desc "Reindex all searchkick models"
task reindex_searchkick: [:environment] do
  system("rake searchkick:reindex:all")
end

desc "Disable searchkick callbacks"
task disable_searchkick_callbacks: [:environment] do
  Searchkick.disable_callbacks
  puts "Disabled searchkick callbacks."
end

def create_user(options = {})
  user_attributes = { email: "sam@example.com",
                      first_name: "Sam",
                      last_name: "Smith",
                      password: "welcome" }
  attributes = user_attributes.merge(options)

  User.create! attributes

  create_data_for_ace_invoice_organization
  create_data_for_eii_organization
  create_data_for_careforever_organization
end

def create_data_for_ace_invoice_organization
  desc = "Article details is coming soon"
  org = Organization.create! name: "AceInvoice", email: "aceinvoice@example.com", api_key: "9099015ee520e11887eb"
  OrganizationUser.create! organization_id: org.id, user_id: User.first.id

  getting_started_url = org.urls.create! url_pattern: "/pages/*/getting_started", url_rule: :ends_with
  integrations_url = org.urls.create! url_pattern: "/pages/*/integrations", url_rule: :ends_with
  pricing_url = org.urls.create! url_pattern: "pricing", url_rule: :ends_with


  category = org.categories.create! name: "Getting Started"
  a1 = category.articles.create!  title: "How do I put JavaScript code in my website?",
                                  desc: desc,
                                  organization_id: org.id,
                                  temporary: false

  a2 = category.articles.create!  title: "Will putting JavaScript code in my website will make my site slower?",
                                  desc: desc,
                                  organization_id: org.id,
                                  temporary: false


  category = org.categories.create! name: "Integrations"
  a3 = category.articles.create! title: "Do you provide integration with wordpress?",
                                desc: desc,
                                organization_id: org.id,
                                temporary: false

  a4 = category.articles.create!  title: "Do you provide integration for PHP applications?",
                                  desc: desc,
                                  organization_id: org.id,
                                  temporary: false

  category = org.categories.create! name: "Pricing"
  a5 = category.articles.create!  title: "Do I need to put credit card to try it out?",
                            desc: desc,
                            organization_id: org.id,
                            temporary: false

  a6 = category.articles.create!  title: "Do you offer custom plan?",
                            desc: desc,
                            organization_id: org.id,
                            temporary: false

  a7 = category.articles.create!  title: "Do you offer discount on yearly plan?",
                            desc: desc,
                            organization_id: org.id,
                            temporary: false

  ArticleUrl.create! article_id: a1.id, url_id: getting_started_url.id
  ArticleUrl.create! article_id: a3.id, url_id: getting_started_url.id
  ArticleUrl.create! article_id: a1.id, url_id: pricing_url.id
  ArticleUrl.create! article_id: a3.id, url_id: integrations_url.id
  ArticleUrl.create! article_id: a5.id, url_id: integrations_url.id
  ArticleUrl.create! article_id: a7.id, url_id: getting_started_url.id

  Ticket.create!  name: "Sam Smith",
                  email: "sam@example.com",
                  message: "How do I put Help articles on my website",
                  organization_id: org.id,
                  note: ''
end

def create_data_for_eii_organization
  desc = "Article details is coming soon"
  org = Organization.create! name: "EventsInIndia", email: "eventsinindia@example.com", api_key: "9099015ee520e11887fb"
  OrganizationUser.create! organization_id: org.id, user_id: User.first.id

  events_url = org.urls.create! url_pattern: "events/city/*", url_rule: "contains"
  subscription_url = org.urls.create! url_pattern: "/city_subscription/new", url_rule: "ends_with"
  pricing_url = org.urls.create! url_pattern: "/pricing", url_rule: "ends_with"

  category = org.categories.create! name: "Events"
  a1 = category.articles.create!  title: "Can I post private events?",
                                  desc: desc,
                                  organization_id: org.id,
                                  temporary: false

  a2 = category.articles.create!  title: "Do you email events information to users immediately or next day?",
                                  desc: desc,
                                  organization_id: org.id,
                                  temporary: false


  category = org.categories.create! name: "Buying tickets"
  a3 = category.articles.create! title: "Can I buy tickets using credit card?",
                                desc: desc,
                                organization_id: org.id,
                                temporary: false

  a4 = category.articles.create!  title: "Can I buy tickets using paytm?",
                                  desc: desc,
                                  organization_id: org.id,
                                  temporary: false

  category = Category.create! name: "Pricing", organization_id: org.id
  a5 = category.articles.create!  title: "Can you waive service fee for events happening in colleges?",
                            desc: desc,
                            organization_id: org.id,
                            temporary: false

  a6 = category.articles.create!  title: "Is the service lower if amount in paid in cash?",
                            desc: desc,
                            organization_id: org.id,
                            temporary: false

  ArticleUrl.create! article_id: a1.id, url_id: events_url.id
  ArticleUrl.create! article_id: a2.id, url_id: events_url.id

  ArticleUrl.create! article_id: a3.id, url_id: subscription_url.id
  ArticleUrl.create! article_id: a4.id, url_id: subscription_url.id

  ArticleUrl.create! article_id: a5.id, url_id: pricing_url.id
  ArticleUrl.create! article_id: a6.id, url_id: pricing_url.id


  Ticket.create!  name: "Sam Smith",
                  email: "sam@example.com",
                  message: "How do I put Help articles on my website",
                  organization_id: org.id,
                  note: ''


end

def create_data_for_careforever_organization
  desc = "Article details is coming soon"
  org = Organization.create! name: "CareForever", email: "careforever@example.com", api_key: "8c83e37f9789819be471"
  OrganizationUser.create! organization_id: org.id, user_id: User.first.id

  about_url = org.urls.create! url_pattern: "/pages/about", url_rule: :contains
  careplan_url = org.urls.create! url_pattern: "/pages/careplan" , url_rule: :contains
  security_url = org.urls.create! url_pattern: "/pages/security", url_rule: :ends_with


  category = org.categories.create! name: "About"
  a1 = category.articles.create!  title: "How do I put JavaScript code in my website?",
                                  desc: desc,
                                  organization_id: org.id,
                                  temporary: false

  a2 = category.articles.create!  title: "Will putting JavaScript code in my website will make my site slower?",
                                  desc: desc,
                                  organization_id: org.id,
                                  temporary: false


  category = org.categories.create! name: "Careplan"
  a3 = category.articles.create! title: "Do you provide integration with wordpress?",
                                desc: desc,
                                organization_id: org.id,
                                temporary: false

  a4 = category.articles.create!  title: "Do you provide integration for PHP applications?",
                                  desc: desc,
                                  organization_id: org.id,
                                  temporary: false

  category = org.categories.create! name: "Security"
  a5 = category.articles.create!  title: "Do I need to put credit card to try it out?",
                            desc: desc,
                            organization_id: org.id,
                            temporary: false

  a6 = category.articles.create!  title: "Do you offer custom plan?",
                            desc: desc,
                            organization_id: org.id,
                            temporary: false

  a7 = category.articles.create!  title: "Do you offer discount on yearly plan?",
                            desc: desc,
                            organization_id: org.id,
                            temporary: false

  ArticleUrl.create! article_id: a1.id, url_id: about_url.id
  ArticleUrl.create! article_id: a3.id, url_id: about_url.id
  ArticleUrl.create! article_id: a1.id, url_id: careplan_url.id
  ArticleUrl.create! article_id: a3.id, url_id: security_url.id
  ArticleUrl.create! article_id: a5.id, url_id: security_url.id
  ArticleUrl.create! article_id: a7.id, url_id: careplan_url.id

  Ticket.create!  name: "Sam Smith",
                  email: "sam@example.com",
                  message: "How do I put Help articles on my website",
                  organization_id: org.id,
                  note: ''

end

def delete_all_records_from_all_tables
  ActiveRecord::Base.connection.schema_cache.clear!

  OrganizationUser.delete_all
  ArticleUrl.delete_all
  ArticleCategory.delete_all
  User.delete_all
  Article.delete_all
  Comment.delete_all
  Ticket.delete_all
  Url.delete_all
  Setting.delete_all
  Category.delete_all
  Organization.delete_all

  ApplicationRecord.descendants.each do |klass|
    klass.reset_column_information
    klass.delete_all
  end
end
