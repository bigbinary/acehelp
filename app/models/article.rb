# frozen_string_literal: true

class Article < ApplicationRecord
  searchkick

  belongs_to :category
  belongs_to :organization
  has_many :article_urls
  has_many :urls, through: :article_urls
  has_many_attached :images

  validates :title, uniqueness: { scope: [:organization_id, :category_id] }, presence: true

  scope :for_organization, ->(org) { where(organization: org) }

  def increment_upvote
    self.update(upvotes_count: self.upvotes_count + 1)
  end

  def increment_downvote
    self.update(downvotes_count: self.downvotes_count + 1)
  end

  def self.search_using(article_id, url, org)
    if article_id.present? && url.present?
      Url.find_by!(url: url).articles.where(id: article_id).for_organization(org)
    elsif article_id.present?
      Article.where(id: article_id).for_organization(org)
    elsif url.present?
      Url.find_by!(url: url).articles.for_organization(org)
    else
      Article.for_organization(org)
    end
  end
end
