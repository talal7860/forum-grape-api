module V1
  class Forums < Grape::API
    include V1Base
    include AuthenticateRequest
    include ForumBase

    VALID_PARAMS = %w(title description)

    helpers do
      def forum_params
        params.select{|key,value| VALID_PARAMS.include?(key.to_s)}
      end
    end

    resource :forums do

      desc 'Get forums', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
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
        forums = Forum.all.order("status, created_at DESC").page(page).per(per_page)
        serialization = ActiveModel::Serializer::CollectionSerializer.new(forums, each_serializer: ForumSerializer)
        render_success(serialization.as_json , pagination_dict(forums))
      end

      desc 'Create new forum', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 201, message: 'success' },
          { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' },
          { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
        ]
      }
      params do
        requires :title, type: String, desc: 'Forum Title'
        requires :description, type: String, desc: 'Forum Description'
      end
      post do
        authenticate_admin!
        forum = Forum.new(forum_params)
        if forum.save
          serialization = ForumSerializer.new(forum)
          render_success(serialization.as_json)
        else
          error = forum.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
          return
        end
      end

      desc 'Update forum', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' },
          { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
        ]
      }
      params do
        requires :title, type: String, desc: 'Forum Title'
        requires :description, type: String, desc: 'Forum Description'
      end
      put ':id' do
        authenticate_admin!
        get_forum params[:id]
        if @forum.update(forum_params)
          serialization = ForumSerializer.new(@forum)
          render_success(serialization.as_json)
        else
          error = forum.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
          return
        end
      end


      desc 'Get forum', {
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
        get_forum params[:id]
        serialization = ForumSerializer.new(@forum)
        render_success(serialization.as_json)
      end

      desc 'delete forum', {
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
        get_forum params[:id]
        @forum.destroy
        render_success({ deleted: true })
      end
    end
  end
end
