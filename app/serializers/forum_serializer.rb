class ForumSerializer < BaseSerializer
  attributes :id, :title, :description, :slug, :created_at
  belongs_to :added_by

  def created_at
    object.created_at.to_s(:posted_time)
  end
end
