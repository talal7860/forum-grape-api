class TopicSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :slug, :forum_id
end
