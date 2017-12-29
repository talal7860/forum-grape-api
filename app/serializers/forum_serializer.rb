class ForumSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :slug, :created_at

  def created_at
    object.created_at.to_s(:posted_time)
  end
end
