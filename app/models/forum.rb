class Forum < ApplicationRecord
  validates :title, :description, presence: true
end
