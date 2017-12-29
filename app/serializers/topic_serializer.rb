class TopicSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :slug, :forum_id, :created_at

  def created_at
    object.created_at.to_s(:posted_time)
  end
end
