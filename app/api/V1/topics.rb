module V1
  class Topics < Grape::API
    include V1Base
    include AuthenticateRequest
    include ForumBase
    include TopicBase

    VALID_PARAMS = %w(title description)

    helpers do
      def topic_params
        params.select{|key,value| VALID_PARAMS.include?(key.to_s)}
      end
    end

    namespace :forums do
      route_param :forum_id, type: String do
        resource :topics do

          desc 'Get topics', {
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
              topics = Topic.query(q, page, per_page, @forum.id)#.order("created_at DESC")
              data = topics.results
            else
              topics = @forum.topics.page(page).per(per_page)
              data = topics
            end
            serialization = ActiveModel::Serializer::CollectionSerializer.new(data, each_serializer: TopicSerializer)
            render_success(serialization.as_json , pagination_dict(topics))
          end

          desc 'Create new topic', {
            consumes: [ "application/x-www-form-urlencoded" ],
            headers: HEADERS_DOCS,
            http_codes: [
              { code: 201, message: 'success' },
              { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' },
              { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
            ]
          }
          params do
            requires :title, type: String, desc: 'Topic Title'
            requires :description, type: String, desc: 'Topic Description'
          end
          post do
            authenticate!
            get_forum params[:forum_id]
            custom_params = topic_params
            custom_params.merge!({forum_id: @forum.id})
            topic = current_user.topics.new(custom_params)
            if topic.save
              serialization = TopicSerializer.new(topic)
              render_success(serialization.as_json)
            else
              error = topic.errors.full_messages.join(', ')
              render_error(RESPONSE_CODE[:unprocessable_entity], error)
              return
            end
          end

          desc 'Update topic', {
            consumes: [ "application/x-www-form-urlencoded" ],
            headers: HEADERS_DOCS,
            http_codes: [
              { code: 200, message: 'success' },
              { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' },
              { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
            ]
          }
          params do
            requires :title, type: String, desc: 'Topic Title'
            requires :description, type: String, desc: 'Topic Description'
          end
          put ':id' do
            authenticate_admin!
            get_topic params[:id]
            if @topic.update(topic_params)
              serialization = TopicSerializer.new(@topic)
              render_success(serialization.as_json)
            else
              error = topic.errors.full_messages.join(', ')
              render_error(RESPONSE_CODE[:unprocessable_entity], error)
              return
            end
          end


          desc 'Get topic', {
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
            get_topic params[:id]
            serialization = TopicSerializer.new(@topic)
            render_success(serialization.as_json)
          end

          desc 'delete topic', {
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
            get_topic params[:id]
            @topic.destroy
            render_success({ deleted: true })
          end
        end
      end
    end
  end
end
