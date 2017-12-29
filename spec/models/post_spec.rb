require 'rails_helper'

RSpec.describe Post, type: :model do
  describe '#create' do
    it 'should create a post without errors' do
      expect {
        FactoryBot::create(:post)
      }.to change(Post, :count).by(1)
    end
  end
end
