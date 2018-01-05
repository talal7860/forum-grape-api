require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#create' do
    it 'should create a user without errors' do
      expect {
        FactoryBot.create(:user)
      }.to change(User, :count).by(1)
    end
  end
end
