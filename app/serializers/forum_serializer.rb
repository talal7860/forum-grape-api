class ForumSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :slug
end
