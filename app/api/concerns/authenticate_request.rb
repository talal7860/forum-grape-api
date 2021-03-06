require 'api_exception'

module AuthenticateRequest
  extend ActiveSupport::Concern

  included do
    helpers do
      # Devise methods overwrites
      def current_user
        return nil if request.headers['Authorization'].blank?
        @current_user ||= User.by_auth_token(request.headers['Authorization'])
      end
      # Authenticate request with token of user
      #
      def authenticate_admin!
        authenticate!
        raise forbidden_error! unless current_user.admin?
      end

      def authenticate!
        raise unauthenticated_error! unless current_user
      end

      def authenticate_topic_owner!(topic)
        authenticate!
        raise forbidden_error! unless current_user.admin? || current_user.moderator?(topic.forum_id) || current_user.owner?(topic)
      end

      def authenticate_post_owner!(post)
        authenticate!
        raise forbidden_error! unless current_user.admin? || current_user.moderator?(post.topic.forum_id) || current_user.owner?(post)
      end

      def unauthenticated_error!
        error!({meta: {code: RESPONSE_CODE[:unauthorized], message: I18n.t("errors.not_authenticated"), debug_info: ''}}, RESPONSE_CODE[:unauthorized])
      end

      def forbidden_error!
        error!({meta: {code: RESPONSE_CODE[:forbidden], message: I18n.t("errors.forbidden"), debug_info: ''}}, RESPONSE_CODE[:forbidden])
      end
    end
  end
end
