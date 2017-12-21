class Post < ApplicationRecord
  belongs_to :added_by, class_name: 'User', foreign_key: :added_by_id
  belongs_to :topic
end
