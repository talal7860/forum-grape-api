module TopicBase
  extend ActiveSupport::Concern
  included do
    helpers do

      def get_topic(id)
        @topic = Topic.find_by_id(id)

        unless @topic
          raise ApiException.new(
            http_status: RESPONSE_CODE[:not_found],
            code: RESPONSE_CODE[:not_found],
            message: I18n.t('errors.topic.not_found')
          )
        end
      end

      def get_forum(id)
        @forum = Forum.find_by_slug(id)

        unless @forum
          raise ApiException.new(
            http_status: RESPONSE_CODE[:not_found],
            code: RESPONSE_CODE[:not_found],
            message: I18n.t('errors.forum.not_found')
          )
        end
      end

    end
  end
end
