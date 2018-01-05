require 'rails_helper'

describe ApplicationApi::V1::Users do
  include Rack::Test::Methods

  def app
    ApplicationApi
  end

  before(:context) do
    header 'Content-Type', 'application/json'
  end

  context :user do
    describe 'Authenticated Request' do

      let (:authenticate!) do
        user = FactoryBot.create(:user)
        user.login!
        header 'Authorization', user.user_tokens.first.token
      end

      let (:user) do
        FactoryBot.attributes_for(:user, avatar: Faker::Avatar.image)
      end

      it 'cannot create a user' do
        authenticate!
        post '/api/users', user.to_json
        expect(last_response.status).to eq(403)
      end

      it 'cannot deletes a user' do
        authenticate!
        created_user = User.create(user)
        delete "/api/users/#{created_user.id}"

        expect(last_response.status).to eq(403)
      end

      it 'cannot get all users' do
        authenticate!
        FactoryBot.create_list(:user, 5)
        get '/api/users/all'

        expect(last_response.status).to eq(403)
      end

      it 'cannot get details of a user' do
        authenticate!
        created_user = User.create(user)
        get "/api/users/#{created_user.id}"
        expect(last_response.status).to eq(403)
      end

    end
    describe 'Un Authenticated Request' do

      let (:user) do
        FactoryBot.attributes_for(:user, avatar: Faker::Avatar.image)
      end

      let (:add_headers) do
      end

      it 'can signup' do
        add_headers
        post '/api/users', user.to_json

        expect(last_response.status).to eq(201)
      end

      it 'cannot delete a user' do
        add_headers
        created_user = User.create(user)
        delete "/api/users/#{created_user.id}"

        expect(last_response.status).to eq(401)
      end

      it 'cannot get all user' do
        add_headers
        FactoryBot.create_list(:user, 5)
        get '/api/users/all'

        expect(last_response.status).to eq(401)
      end

      it 'cannot get details of a user' do
        add_headers
        created_user = User.create(user)
        get "/api/users/#{created_user.id}"
        expect(last_response.status).to eq(401)
      end

    end

  end

  context :admin do
    describe 'Authenticated Request' do
      let (:authenticate!) do
        admin = FactoryBot.create(:admin)
        admin.login!
        header 'Authorization', admin.user_tokens.first.token
      end
      let (:user) do
        FactoryBot.attributes_for(:user, avatar: Faker::Avatar.image)
      end

      it 'can creates a user' do
        authenticate!
        post '/api/users', user.to_json

        expect(last_response.status).to eq(201)
      end

      it 'can update any user' do
        authenticate!
        user = FactoryBot.create(:user)
        user.first_name = 'Yo Yo YO'
        put "/api/users/#{user.id}", user.to_json

        expect(last_response.status).to eq(200)
      end

      it 'can delete any user' do
        authenticate!
        created_user = User.create(user)
        delete "/api/users/#{created_user.id}"

        expect(last_response.status).to eq(200)
      end

      it 'gets all users' do
        authenticate!
        FactoryBot.create_list(:user, 5)
        get '/api/users/all'

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data'].count).to eq(6)
      end

      it 'gets details of a any user' do
        authenticate!
        user = FactoryBot.create(:user)
        get "/api/users/#{user.id}"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data']['id']).to eq(user.id)
      end

      it 'cannot get details of a an invalid user id' do
        authenticate!
        get "/api/users/199"
        expect(last_response.status).to eq(404)
      end

    end
  end
end
