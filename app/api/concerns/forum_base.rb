module ForumBase
  extend ActiveSupport::Concern
  included do
    helpers do

      def get_forum(slug)
        @forum = Forum.find_by_slug(slug)

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

