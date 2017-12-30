require 'rails_helper'

describe ApplicationApi::V1::Forums do
  include Rack::Test::Methods

  def app
    ApplicationApi
  end

  before(:context) do
  end

  context :user do
    describe 'Authenticated Request' do
      let (:authenticate!) do
        user = FactoryBot.create(:admin)
        user.login!
        header 'Content-Type', 'application/json'
        header 'Authorization', user.user_tokens.first.token
      end
      let (:forum) do
        FactoryBot::build(:forum)
      end

      it 'creates a forum' do
        authenticate!
        post '/api/forums', forum.to_json
        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)['data']['title']).to eq(forum.title)
      end

      it 'deletes a forum' do
        authenticate!
        forum.save!
        delete "/api/forums/#{forum.slug}"

        expect(last_response.status).to eq(200)
      end

      it 'gets all forums' do
        authenticate!
        FactoryBot::create_list(:forum, 5)
        get '/api/forums/all'

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data'].count).to eq(5)
      end

      it 'gets details of a forum' do
        authenticate!
        forum.save!
        get "/api/forums/#{forum.slug}"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data']['id']).to eq(forum.id)
      end

    end
    describe 'Un Authenticated Request' do
      let (:forum) do
        FactoryBot::build(:forum)
      end

      it 'does not create a forum' do
        post '/api/forums', forum.to_json

        expect(last_response.status).to eq(400)
      end

      it 'does not delete a forum' do
        forum.save!
        delete "/api/forums/#{forum.slug}"

        expect(last_response.status).to eq(401)
      end

      it 'gets all forum' do
        FactoryBot::create_list(:forum, 5)
        get '/api/forums/all'

        expect(last_response.status).to eq(200)
      end

      it 'gets details of a forum' do
        forum.save!
        get "/api/forums/#{forum.slug}"
        expect(last_response.status).to eq(200)
      end

    end

  end

  context :user do
    describe 'Authenticated Request' do
      let (:authenticate!) do
        user = FactoryBot.create(:user)
        user.login!
        header 'Content-Type', 'application/json'
        header 'Authorization', user.user_tokens.first.token
      end
      let (:forum) do
        FactoryBot::build(:forum, added_by: nil)
      end

      it 'does not create a forum' do
        authenticate!
        post '/api/forums', forum.to_json

        expect(last_response.status).to eq(401)
      end

      it 'cannot delete a forum' do
        authenticate!
        forum.added_by = FactoryBot.create(:user)
        forum.save!
        delete "/api/forums/#{forum.slug}"

        expect(last_response.status).to eq(401)
      end
    end
  end

  context :admin do
    describe 'Authenticated Request' do
      let (:authenticate!) do
        admin = FactoryBot.create(:admin)
        admin.login!
        header 'Content-Type', 'application/json'
        header 'Authorization', admin.user_tokens.first.token
      end
      let (:forum) do
        FactoryBot::build(:forum)
      end

      it 'can creates a forum against any user' do
        authenticate!
        forum.added_by = FactoryBot.create(:user)
        post '/api/forums', forum.to_json

        expect(last_response.status).to eq(201)
      end

      it 'can delete any forum' do
        authenticate!
        forum.save!
        delete "/api/forums/#{forum.slug}"

        expect(last_response.status).to eq(200)
      end

      it 'gets all forums' do
        authenticate!
        FactoryBot::create_list(:forum, 5)
        get '/api/forums/all'

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data'].count).to eq(5)
      end

      it 'gets details of a any forum' do
        authenticate!
        forum = FactoryBot.create(:forum)
        get "/api/forums/#{forum.slug}"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data']['id']).to eq(forum.id)
      end

      it 'can assign a moderator to a forum' do
        authenticate!
        forum = FactoryBot.create(:forum, added_by: User.first)
        post "/api/forums/#{forum.slug}/add-moderator", { user_id: FactoryBot::create(:user).id }.to_json
        expect(last_response.status).to eq(201)
      end

      it 'cannot assign a moderator forum to itself' do
        authenticate!
        forum = FactoryBot.create(:forum, added_by: User.first)
        post "/api/forums/#{forum.slug}/add-moderator", { user_id: User.first.id }.to_json
        expect(last_response.status).to eq(422)
      end

    end
  end
end

