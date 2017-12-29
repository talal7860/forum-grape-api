class Topic < ApplicationRecord
  belongs_to :forum
  belongs_to :added_by, class_name: 'User', foreign_key: :added_by_id
  has_many :posts
  after_create :create_slug
  searchkick

  private

  def create_slug
    slug = "#{self.title} #{self.id}".parameterize
    self.update_columns(slug: slug)
  end

  def search_data
    {
      title: title,
      description: description,
      forum_id: forum_id
    }
  end

  def self.query(q, page, per_page, forum_id)
    self.search(q, fields: ['title', 'description'], page: page, per_page: per_page, where: {
      forum_id: forum_id
    })
  end
end
