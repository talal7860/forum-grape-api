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

      def get_user(id)
        @user = User.find_by_id(id)

        unless @user
          raise ApiException.new(
            http_status: RESPONSE_CODE[:not_found],
            code: RESPONSE_CODE[:not_found],
            message: I18n.t('errors.user.not_found')
          )
        end
      end

      def can_add_moderator!(forum_slug, user_id)
        get_forum(forum_slug)
        get_user(user_id)

        if @forum.added_by_id == @user.id
          raise ApiException.new(
            http_status: RESPONSE_CODE[:unprocessable_entity],
            code: RESPONSE_CODE[:unprocessable_entity],
            message: I18n.t('errors.forum.self_moderator')
          )
        end
      end

    end
  end
end

