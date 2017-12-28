class Topic < ApplicationRecord
  belongs_to :forum
  belongs_to :added_by, class_name: 'User', foreign_key: :added_by_id
  after_create :create_slug

  private

  def create_slug
    slug = "#{self.title} #{self.id}".parameterize
    self.update_columns(slug: slug)
  end
end
