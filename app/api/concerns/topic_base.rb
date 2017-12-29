module TopicBase
  extend ActiveSupport::Concern
  included do
    helpers do

      def get_topic(slug)
        @topic = Topic.find_by_slug(slug)

        unless @topic
          raise ApiException.new(
            http_status: RESPONSE_CODE[:not_found],
            code: RESPONSE_CODE[:not_found],
            message: I18n.t('errors.topic.not_found')
          )
        end
      end

    end
  end
end
