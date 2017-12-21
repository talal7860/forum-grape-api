class Forum < ApplicationRecord
  validates :title, :description, presence: true
  belongs_to :added_by, class_name: 'User', foreign_key: :added_by_id
end
