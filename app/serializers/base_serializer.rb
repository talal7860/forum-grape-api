class BaseSerializer < ActiveModel::Serializer
  def attachment_url(url)
    unless Rails.env.production?
      "#{ENV.fetch('BASE_URL', 'http://localhost:3000')}#{url}"
    else
      url
    end
  end
end
