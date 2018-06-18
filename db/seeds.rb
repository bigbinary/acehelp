# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
org1 = Organization.find_or_create_by! name: "ace-invoice"
org2 = Organization.find_or_create_by! name: "healthcity"

c1 = Category.find_or_create_by! name: "Getting Started"
a1 = c1.articles.find_or_create_by! title: "How do I put JavaScript code in my website?", desc: "coming soon", organization_id: org1.id
a2 = c1.articles.find_or_create_by! title: "Will putting JavaScript code in my website will make my site slower?", desc: "coming soon", organization_id: org2.id

c2 = Category.find_or_create_by! name: "Integrations"
a3 = c2.articles.find_or_create_by! title: "Do you provide integration with wordpress?", desc: "coming soon", organization_id: org1.id
a4 = c2.articles.find_or_create_by! title: "Do you provide integration for PHP applications?", desc: "coming soon", organization_id: org2.id

c3 = Category.find_or_create_by! name: "Pricing"
a5 = c3.articles.find_or_create_by! title: "Do I need to put credit card to try it out?", desc: "coming soon", organization_id: org1.id
a6 = c3.articles.find_or_create_by! title: "Do you offer custom plan?", desc: "coming soon", organization_id: org2.id
a7 = c3.articles.find_or_create_by! title: "Do you offer discount on yearly plan?", desc: "coming soon", organization_id: org1.id

u1 = org1.urls.find_or_create_by! url: "http://aceinvoice.com/getting-started"
u2 = org1.urls.find_or_create_by! url: "http://aceinvoice.com/integrations"
u3 = org1.urls.find_or_create_by! url: "http://aceinvoice.com/pricing"

u5 = org2.urls.find_or_create_by! url: "http://healthcity.com/getting-started"
u6 = org2.urls.find_or_create_by! url: "http://healthcity.com/integrations"
u7 = org2.urls.find_or_create_by! url: "http://healthcity.com/pricing"

ArticleUrl.find_or_create_by! article_id: a1.id, url_id: u1.id
ArticleUrl.find_or_create_by! article_id: a3.id, url_id: u1.id
ArticleUrl.find_or_create_by! article_id: a1.id, url_id: u3.id
ArticleUrl.find_or_create_by! article_id: a3.id, url_id: u2.id
ArticleUrl.find_or_create_by! article_id: a5.id, url_id: u2.id
ArticleUrl.find_or_create_by! article_id: a7.id, url_id: u1.id

ArticleUrl.find_or_create_by! article_id: a2.id, url_id: u5.id
ArticleUrl.find_or_create_by! article_id: a4.id, url_id: u5.id
ArticleUrl.find_or_create_by! article_id: a6.id, url_id: u6.id
ArticleUrl.find_or_create_by! article_id: a2.id, url_id: u7.id
ArticleUrl.find_or_create_by! article_id: a4.id, url_id: u6.id
ArticleUrl.find_or_create_by! article_id: a6.id, url_id: u7.id

user1 = User.find_or_initialize_by email: "tony@example.com", first_name: "Tony", last_name: "Stark"
user1.password = "welcome"
user1.save!
