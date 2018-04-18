# frozen_string_literal: true

module Application
  module V1
    # Posts API Class
    class Posts < Grape::API
      include V1Base
      include AuthenticateRequest
      include ForumBase
      include TopicBase
      include PostBase

      VALID_PARAMS = %w[content].freeze

      helpers do
        def post_params
          params.select { |key| VALID_PARAMS.include?(key.to_s) }
        end
      end

      namespace :forums do
        route_param :forum_slug, type: String do
          namespace :topics do
            route_param :topic_slug, type: String do
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
                  get_topic params[:topic_slug]
                  page = (params[:page] || 1).to_i
                  per_page = (params[:per_page] || PER_PAGE).to_i
                  q = params[:q] || ""
                  if q.present?
                    posts = Post.include_added_by.query(q, page, per_page, @forum.id)#.order("created_at DESC")
                    data = posts.results
                  else
                    posts = @topic.posts.include_added_by.page(page).per(per_page)
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
                  requires :content, type: String, desc: 'Post Content'
                end
                post do
                  authenticate!
                  get_topic params[:topic_slug]
                  custom_params = post_params
                  custom_params.merge!({topic_id: @topic.id})
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
                  requires :content, type: String, desc: 'Post Content'
                end
                put ':id' do
                  get_post params[:id]
                  authenticate_post_owner!(@post)
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
                    { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
                  ]
                }
                get ':id' do
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
                  get_post params[:id]
                  authenticate_post_owner!(@post)
                  @post.destroy
                  render_success({ deleted: true })
                end
              end
            end
          end
        end
      end
    end
  end
end
