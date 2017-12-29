class User < ApplicationRecord
  rolify
  after_create :assign_default_role
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :first_name, :last_name, presence: true
  validates :username, presence: true, uniqueness: true

  has_many :forums, foreign_key: :added_by_id, dependent: :destroy
  has_many :topics, foreign_key: :added_by_id, dependent: :destroy
  has_many :posts, foreign_key: :added_by_id, dependent: :destroy
  has_many :user_tokens, dependent: :destroy

  ## Callbacks
  before_save do
    self.email = email.downcase if email_changed?
  end

  ## Methods
  def self.by_auth_token(token)
    user_token = UserToken.where(token: token).first
    user_token ? user_token.user : nil
  end

  def name
    "#{first_name} #{last_name}"
  end

  def login!
    self.user_tokens.create
  end

  def poster?
    self.has_role? :poster
  end

  def admin?
    self.has_role? :admin
  end

  def moderator?(forum_id)
    self.has_role? :moderator, Forum.find_by_id(forum_id)
  end

  def owner?(resource)
    resource.added_by_id == self.id
  end

  private

  def assign_default_role
    self.add_role(:poster)
  end
end
