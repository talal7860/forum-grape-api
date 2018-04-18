require 'rails_helper'

describe V1::Posts do
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

      let (:topic) do
        FactoryBot.build(:topic)
      end

      let (:post_instance) do
        FactoryBot.build(:post, added_by: nil)
      end

      it 'creates a post' do
        authenticate!
        post "/api/forums/#{post_instance.topic.forum.slug}/topics/#{post_instance.topic.slug}/posts", post_instance.to_json

        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)['data']['content']).to eq(post_instance.content)
      end

      it 'deletes a post' do
        authenticate!
        post_instance.added_by = User.first
        post_instance.save!
        delete "/api/forums/#{post_instance.topic.forum.slug}/topics/#{post_instance.topic.slug}/posts/#{post_instance.id}"

        expect(last_response.status).to eq(200)
      end

      it 'gets all tickets for a topic' do
        authenticate!
        topic.save!
        FactoryBot.create_list(:post, 5)
        FactoryBot.create_list(:post, 5, added_by: User.first, topic: topic)
        get "/api/forums/#{topic.forum.slug}/topics/#{topic.slug}/posts/all"

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data'].count).to eq(5)
      end

      it 'gets details of a post' do
        authenticate!
        post_instance.added_by = User.first
        post_instance.save!
        get "/api/forums/#{post_instance.topic.forum.slug}/topics/#{post_instance.topic.slug}/posts/#{post_instance.id}"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data']['id']).to eq(post_instance.id)
      end

    end
    describe 'Un Authenticated Request' do
      let (:post_instance) do
        FactoryBot.build(:post, added_by: nil)
      end

      it 'does not creates a post' do
        topic = FactoryBot.create(:topic)
        post "/api/forums/#{topic.forum.slug}/topics/#{topic.slug}/posts", post_instance.to_json

        expect(last_response.status).to eq(401)
      end

      it 'does not deletes a post' do
        user = FactoryBot.create(:user)
        post_instance.added_by = user
        post_instance.save!
        delete "/api/forums/#{post_instance.topic.forum.slug}/topics/#{post_instance.topic.slug}/posts/#{post_instance.id}"

        expect(last_response.status).to eq(401)
      end

      it 'gets all posts' do
        FactoryBot.create_list(:post, 5)
        get "/api/forums/#{post_instance.topic.forum.slug}/topics/#{post_instance.topic.slug}/posts/all"

        expect(last_response.status).to eq(200)
      end

      it 'gets details of a post' do
        user = FactoryBot.create(:user)
        post_instance.added_by = user
        post_instance.save!
        get "/api/forums/#{post_instance.topic.forum.slug}/topics/#{post_instance.topic.slug}/posts/#{post_instance.id}"
        expect(last_response.status).to eq(200)
      end

    end

  end

  context :poster do
    describe 'Authenticated Request' do
      let (:authenticate!) do
        user = FactoryBot.create(:user)
        user.login!
        header 'Authorization', user.user_tokens.first.token
      end
      let (:post_instance) do
        FactoryBot.build(:post, added_by: nil)
      end

      it 'cannot update a post not owned' do
        authenticate!
        post_instance = FactoryBot.create(:post)
        put "/api/forums/#{post_instance.topic.forum.slug}/topics/#{post_instance.topic.slug}/posts/#{post_instance.id}", post_instance.to_json

        expect(last_response.status).to eq(403)
      end

      it 'cannot delete a post not owned' do
        authenticate!
        post_instance = FactoryBot.create(:post)
        delete "/api/forums/#{post_instance.topic.forum.slug}/topics/#{post_instance.topic.slug}/posts/#{post_instance.id}"

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
      let (:post_instance) do
        FactoryBot.build(:post)
      end

      it 'cant update a post not owned' do
        authenticate!
        post_instance = FactoryBot.create(:post)
        put "/api/forums/#{post_instance.topic.forum.slug}/topics/#{post_instance.topic.slug}/posts/#{post_instance.id}", post_instance.to_json

        expect(last_response.status).to eq(200)
      end

      it 'can delete a post not owned' do
        authenticate!
        post_instance = FactoryBot.create(:post)
        delete "/api/forums/#{post_instance.topic.forum.slug}/topics/#{post_instance.topic.slug}/posts/#{post_instance.id}"

        expect(last_response.status).to eq(200)
      end

    end
  end
end

