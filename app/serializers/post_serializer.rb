class PostSerializer < ActiveModel::Serializer
  attributes :id, :content, :created_at, :topic_id

  def created_at
    object.created_at.to_s(:posted_time)
  end
end
