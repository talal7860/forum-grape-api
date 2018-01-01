class UserSerializer < BaseSerializer
  attributes :id, :first_name, :last_name, :email, :phone_number, :username, :name, :created_at, :avatar

  attribute :token, if: :show_token?

  def show_token?
    self.instance_options[:show_token]
  end

  def created_at
    object.created_at.to_s(:short)
  end

  def token
    self.instance_options[:token]
  end

  def avatar
    {
      original: attachment_url(object.avatar.url),
      medium: attachment_url(object.avatar.url(:medium)),
      thumb: attachment_url(object.avatar.url(:thumb)),
    }
  end
end
