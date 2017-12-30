class Forum < ApplicationRecord
  validates :title, :description, presence: true
  belongs_to :added_by, class_name: 'User', foreign_key: :added_by_id
  has_many :topics, dependent: :destroy
  after_create :create_slug

  def add_moderator(user)
    user.add_role :moderator, self
  end

  private

  def create_slug
    slug = "#{self.title} #{self.id}".parameterize
    self.update_columns(slug: slug)
  end
end
