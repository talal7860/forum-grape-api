require 'rails_helper'

RSpec.describe Forum, type: :model do
  describe '#create' do
    it 'should create a forum without errors' do
      expect {
        FactoryBot::create(:forum)
      }.to change(Forum, :count).by(1)
    end
  end
end
