require 'rails_helper'

RSpec.describe Topic, type: :model do
  describe '#create' do
    it 'should create a topic without errors' do
      expect {
        FactoryBot::create(:topic)
      }.to change(Topic, :count).by(1)
    end
  end
end
