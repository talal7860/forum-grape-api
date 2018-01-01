class PostSerializer < BaseSerializer
  attributes :id, :content, :created_at, :topic_id
  belongs_to :added_by

  def created_at
    object.created_at.to_s(:posted_time)
  end
end
