require 'rails_helper'

describe ApplicationApi::V1::Sessions do
  include Rack::Test::Methods

  def app
    ApplicationApi
  end

  describe 'POST /api/sessions' do
    let(:user) { FactoryBot.create(:user, email: 'customer@customer.com') }
    let (:body) do
      {
        email: 'customer@customer.com',
        password: 'password'
      }
    end

    it 'creates a token for logging in' do
      user
      post '/api/sessions', body, { 'Content-Type' => 'application/json' }

      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)['data']['token']).to eq(UserToken.first.token)
    end

    it 'does not create a token for invalid user name password' do
      user
      post '/api/sessions', {email: 'customer@customer.com', password: 'asdf'}, { 'Content-Type' => 'application/json' }

      expect(last_response.status).to eq(401)
    end
  end

  describe 'DELETE /api/sessions' do
    let(:user) { FactoryBot.create(:user, email: 'customer@customer.com') }

    it 'deletes a valid session' do
      user.login!
      puts user.user_tokens.first.token
      header 'Content-Type', 'application/json'
      header 'Authorization', user.user_tokens.first.token
      delete '/api/sessions'

      expect(last_response.status).to eq(200)
      expect(user.user_tokens.count).to eq(0)
    end

    it 'does not delete an invalid session' do
      header 'Content-Type', 'application/json'
      header 'Authorization', 'invalid session'
      delete '/api/sessions'

      expect(last_response.status).to eq(401)
    end
  end

end
