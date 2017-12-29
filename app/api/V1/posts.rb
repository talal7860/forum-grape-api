module V1
  class Posts < Grape::API
    include V1Base
    include AuthenticateRequest
    include ForumBase
    include TopicBase
    include PostBase

    VALID_PARAMS = %w(title description)

    helpers do
      def post_params
        params.select{|key,value| VALID_PARAMS.include?(key.to_s)}
      end
    end

    namespace :forums do
      route_param :forum_id, type: String do
        resource :posts do

          desc 'Get posts', {
            consumes: [ "application/x-www-form-urlencoded" ],
            http_codes: [
              { code: 200, message: 'success' },
            ]
          }
          params do
            optional :page, type: Integer, desc: 'page'
            optional :per_page, type: Integer, desc: 'per_page'
            optional :q, type: String, desc: 'Query String'
          end
          get :all do
            get_forum params[:forum_id]
            page = (params[:page] || 1).to_i
            per_page = (params[:per_page] || PER_PAGE).to_i
            q = params[:q] || ""
            if q.present?
              posts = Post.query(q, page, per_page, @forum.id)#.order("created_at DESC")
              data = posts.results
            else
              posts = @forum.posts.page(page).per(per_page)
              data = posts
            end
            serialization = ActiveModel::Serializer::CollectionSerializer.new(data, each_serializer: PostSerializer)
            render_success(serialization.as_json , pagination_dict(posts))
          end

          desc 'Create new post', {
            consumes: [ "application/x-www-form-urlencoded" ],
            headers: HEADERS_DOCS,
            http_codes: [
              { code: 201, message: 'success' },
              { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' },
              { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
            ]
          }
          params do
            requires :title, type: String, desc: 'Post Title'
            requires :description, type: String, desc: 'Post Description'
          end
          post do
            authenticate!
            get_forum params[:forum_id]
            custom_params = post_params
            custom_params.merge!({forum_id: @forum.id})
            post = current_user.posts.new(custom_params)
            if post.save
              serialization = PostSerializer.new(post)
              render_success(serialization.as_json)
            else
              error = post.errors.full_messages.join(', ')
              render_error(RESPONSE_CODE[:unprocessable_entity], error)
              return
            end
          end

          desc 'Update post', {
            consumes: [ "application/x-www-form-urlencoded" ],
            headers: HEADERS_DOCS,
            http_codes: [
              { code: 200, message: 'success' },
              { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' },
              { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
            ]
          }
          params do
            requires :title, type: String, desc: 'Post Title'
            requires :description, type: String, desc: 'Post Description'
          end
          put ':id' do
            authenticate_admin!
            get_post params[:id]
            if @post.update(post_params)
              serialization = PostSerializer.new(@post)
              render_success(serialization.as_json)
            else
              error = post.errors.full_messages.join(', ')
              render_error(RESPONSE_CODE[:unprocessable_entity], error)
              return
            end
          end


          desc 'Get post', {
            consumes: [ "application/x-www-form-urlencoded" ],
            headers: HEADERS_DOCS,
            http_codes: [
              { code: 200, message: 'success' },
              { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') },
              { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
            ]
          }
          get ':id' do
            authenticate_admin!
            get_post params[:id]
            serialization = PostSerializer.new(@post)
            render_success(serialization.as_json)
          end

          desc 'delete post', {
            consumes: [ "application/x-www-form-urlencoded" ],
            headers: HEADERS_DOCS,
            http_codes: [
              { code: 200, message: 'success' },
              { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') },
              { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
            ]
          }
          delete ':id' do
            authenticate_admin!
            get_post params[:id]
            @post.destroy
            render_success({ deleted: true })
          end
        end
      end
    end
  end
end

