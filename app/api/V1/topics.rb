module V1
  class Topics < Grape::API
    include V1Base
    include AuthenticateRequest
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
          end
          get :all do
            page = (params[:page] || 1).to_i
            per_page = (params[:per_page] || PER_PAGE).to_i
            topics = Topic.all.order("created_at DESC").page(page).per(per_page)
            serialization = ActiveModel::Serializer::CollectionSerializer.new(topics, each_serializer: TopicSerializer)
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
            authenticate_admin!
            topic = Topic.new(topic_params)
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
