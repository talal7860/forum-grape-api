class Post < ApplicationRecord
  belongs_to :added_by, class_name: 'User', foreign_key: :added_by_id
  belongs_to :topic
  scope :include_added_by, -> { includes(:added_by) }
  searchkick

  private

  def search_data
    {
      content: content,
      topic_id: topic_id
    }
  end

  def self.query(q, page, per_page, topic_id)
    self.search(q, fields: ['content'], page: page, per_page: per_page, where: {
      topic_id: topic_id
    })
  end
end
