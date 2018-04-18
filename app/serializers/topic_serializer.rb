class TopicSerializer < BaseSerializer
  attributes :id, :title, :description, :slug, :forum_id, :created_at, :posts_count, :views, :created_at_i
  belongs_to :added_by

  def created_at
    object.created_at.to_s(:posted_time)
  end

  def created_at_i
    object.created_at.to_i
  end

  def posts_count
    #converting to array to make use of includes and avoid n+1 queries
    object.posts.to_a.count
  end

  def views
    # @TODO add views
    Faker::Number.between(20, 250)
  end
end
