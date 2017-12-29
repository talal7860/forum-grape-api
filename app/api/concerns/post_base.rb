module PostBase
  extend ActiveSupport::Concern
  included do
    helpers do

      def get_post(slug)
        @post = Post.find_by_id(slug)

        unless @post
          raise ApiException.new(
            http_status: RESPONSE_CODE[:not_found],
            code: RESPONSE_CODE[:not_found],
            message: I18n.t('errors.post.not_found')
          )
        end
      end

    end
  end
end

