class TopicSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :slug, :forum_id, :created_at, :posts_count, :views

  def created_at
    object.created_at.to_s(:posted_time)
  end

  def posts_count
    object.posts.count
  end

  def views
    # @TODO add views
    Faker::Number.between(20, 250)
  end
end
