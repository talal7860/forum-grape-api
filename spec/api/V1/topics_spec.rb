require 'rails_helper'

describe ApplicationApi::V1::Topics do
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

      let (:forum) do
        FactoryBot.build(:forum)
      end

      let (:topic) do
        FactoryBot.build(:topic, added_by: nil)
      end

      it 'creates a topic' do
        authenticate!
        post "/api/forums/#{topic.forum.slug}/topics", topic.to_json

        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)['data']['title']).to eq(topic.title)
      end

      it 'deletes a topic' do
        authenticate!
        topic.added_by = User.first
        topic.save!
        delete "/api/forums/#{topic.forum.slug}/topics/#{topic.slug}"

        expect(last_response.status).to eq(200)
      end

      it 'gets all tickets for a forum' do
        authenticate!
        forum.save!
        FactoryBot.create_list(:topic, 5)
        FactoryBot.create_list(:topic, 5, added_by: User.first, forum: forum)
        get "/api/forums/#{forum.slug}/topics/all"

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data'].count).to eq(5)
      end

      it 'gets details of a topic' do
        authenticate!
        topic.added_by = User.first
        topic.save!
        get "/api/forums/#{topic.forum.slug}/topics/#{topic.slug}"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data']['id']).to eq(topic.id)
      end

    end
    describe 'Un Authenticated Request' do
      let (:topic) do
        FactoryBot.build(:topic, added_by: nil)
      end

      it 'does not creates a topic' do
        forum = FactoryBot.create(:forum)
        post "/api/forums/#{forum.slug}/topics", topic.to_json

        expect(last_response.status).to eq(401)
      end

      it 'does not deletes a topic' do
        user = FactoryBot.create(:user)
        topic.added_by = user
        topic.save!
        delete "/api/forums/#{topic.forum.slug}/topics/#{topic.slug}"

        expect(last_response.status).to eq(401)
      end

      it 'gets all topics' do
        FactoryBot.create_list(:topic, 5)
        get "/api/forums/#{topic.forum.slug}/topics/all"

        expect(last_response.status).to eq(200)
      end

      it 'gets details of a topic' do
        user = FactoryBot.create(:user)
        topic.added_by = user
        topic.save!
        get "/api/forums/#{topic.forum.slug}/topics/#{topic.slug}"
        expect(last_response.status).to eq(200)
      end

    end

  end

  context :poster do
    describe 'Authenticated Request' do
      let (:authenticate!) do
        user = FactoryBot.create(:user)
        user.login!
        header 'Content-Type', 'application/json'
        header 'Authorization', user.user_tokens.first.token
      end
      let (:topic) do
        FactoryBot.build(:topic, added_by: nil)
      end

      it 'cannot update a topic not owned' do
        authenticate!
        topic = FactoryBot.create(:topic)
        put "/api/forums/#{topic.forum.slug}/topics/#{topic.slug}", topic.to_json

        expect(last_response.status).to eq(403)
      end

      it 'cannot delete a topic not owned' do
        authenticate!
        topic = FactoryBot.create(:topic)
        delete "/api/forums/#{topic.forum.slug}/topics/#{topic.slug}"

        expect(last_response.status).to eq(403)
      end

    end
  end

  context :admin do
    describe 'Authenticated Request' do
      let (:authenticate!) do
        admin = FactoryBot.create(:user)
        admin.add_role(:admin)
        admin.login!
        header 'Authorization', admin.user_tokens.first.token
      end
      let (:topic) do
        FactoryBot.build(:topic)
      end

      it 'cant update a topic not owned' do
        authenticate!
        topic = FactoryBot.create(:topic)
        put "/api/forums/#{topic.forum.slug}/topics/#{topic.slug}", topic.to_json

        expect(last_response.status).to eq(200)
      end

      it 'can delete a topic not owned' do
        authenticate!
        topic = FactoryBot.create(:topic)
        delete "/api/forums/#{topic.forum.slug}/topics/#{topic.slug}"

        expect(last_response.status).to eq(200)
      end

    end
  end
end
