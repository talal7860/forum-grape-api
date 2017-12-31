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
        forums = Forum.all.order("created_at DESC").page(page).per(per_page)
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
        forum = current_user.forums.new(forum_params)
        forum.save
        serialization = ForumSerializer.new(forum)
        render_success(serialization.as_json)
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
        optional :title, type: String, desc: 'Forum Title'
        optional :description, type: String, desc: 'Forum Description'
      end
      put ':slug' do
        authenticate_admin!
        get_forum params[:slug]
        @forum.update(forum_params)
        serialization = ForumSerializer.new(@forum)
        render_success(serialization.as_json)
      end

      desc 'Get forum', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
        ]
      }
      get ':slug' do
        get_forum params[:slug]
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
      delete ':slug' do
        authenticate_admin!
        get_forum params[:slug]
        @forum.destroy
        render_success({ deleted: true })
      end

      desc 'Assign a moderator', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' },
          { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') },
          { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
        ]
      }
      params do
        requires :user_id, type: Integer, desc: 'Moderator ID'
      end
      post ':slug/add-moderator' do
        authenticate_admin!
        can_add_moderator! params[:slug], params[:user_id]
        @forum.add_moderator(@user)
        serialization = ForumSerializer.new(@forum)
        render_success(serialization.as_json)
      end


    end
  end
end
