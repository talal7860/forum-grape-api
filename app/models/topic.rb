class Topic < ApplicationRecord
  belongs_to :forum
  belongs_to :added_by, class_name: 'User', foreign_key: :added_by_id
end
