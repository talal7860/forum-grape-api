class TopicSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :slug
end
