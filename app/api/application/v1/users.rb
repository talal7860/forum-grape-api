# frozen_string_literal: true

module Application
  module V1
    # Users API
    class Users < Grape::API
      include V1Base
      include AuthenticateRequest
      include UserBase

      VALID_PARAMS = %w[email username password password_confirmation first_name last_name phone_number].freeze

      helpers do
        def user_params
          params.select { |key| VALID_PARAMS.include?(key.to_s) }
        end
      end

      resource :users do
        desc 'Get users', {
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
          authenticate_admin!
          page = (params[:page] || 1).to_i
          per_page = (params[:per_page] || PER_PAGE).to_i
          users = User.all.order("created_at DESC").page(page).per(per_page)
          serialization = ActiveModel::Serializer::CollectionSerializer.new(users, each_serializer: UserSerializer)
          render_success(serialization.as_json , pagination_dict(users))
        end

        desc 'Create new user', {
          consumes: [ "application/x-www-form-urlencoded" ],
          http_codes: [
            { code: 201, message: 'success' },
            { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' },
            { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
          ]
        }
        params do
          requires :email, type: String, desc: 'Email'
          requires :username, type: String, desc: 'Username'
          requires :first_name, type: String, desc: 'First Name'
          requires :last_name, type: String, desc: 'Last Name'
          optional :phone_number, type: String, desc: 'Phone Number'
          requires :password, type: String, desc: 'Password'
          requires :password_confirmation, type: String, desc: 'Password Confirmation'
        end
        post do
          can_create_user?
          user = User.new(user_params)
          user.save
          u_token = user.login!
          serialization = UserSerializer.new(user, { show_token: true, token: u_token.token })
          render_success(serialization.as_json)
        end

        desc 'Update user', {
          consumes: [ "application/x-www-form-urlencoded" ],
          headers: HEADERS_DOCS,
          http_codes: [
            { code: 200, message: 'success' },
            { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' },
            { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
          ]
        }
        params do
          optional :email, type: String, desc: 'Email'
          optional :first_name, type: String, desc: 'First Name'
          optional :last_name, type: String, desc: 'Last Name'
          optional :phone_number, type: String, desc: 'Phone Number'
          optional :password, type: String, desc: 'Password'
          optional :password_confirmation, type: String, desc: 'Password Confirmation'
        end
        put ':id' do
          authenticate_admin!
          get_user(params[:id])
          can_update_user?(params[:id])
          @user.update(user_params)
          serialization = UserSerializer.new(@user)
          render_success(serialization.as_json)
        end


        desc 'Get user', {
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
          get_user params[:id]
          serialization = UserSerializer.new(@user)
          render_success(serialization.as_json)
        end

        desc 'delete user', {
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
          get_user params[:id]
          @user.destroy
          render_success({ deleted: true })
        end
      end
    end
  end
end
