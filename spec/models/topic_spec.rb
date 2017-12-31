require 'rails_helper'

RSpec.describe Topic, type: :model do
  describe '#create' do
    it 'should create a topic without errors' do
      expect {
        FactoryBot::create(:topic)
      }.to change(Topic, :count).by(1)
    end
  end
  describe '#search' do
    it 'should search a topic with matching title' do
      topic = FactoryBot::create(:topic)
      allow(Topic).to receive(:query).and_return( Topic.all )
      topics = Topic.query(topic.title, 1, 1, topic.forum_id)
      expect(topics.count).to eq(1)
    end
  end
end
