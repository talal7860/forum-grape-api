require 'factory_bot'
namespace :forum_api do
  desc "TODO"
  task create_dummy_data: :environment do
    User.transaction do
      user = FactoryBot::create(:user)
      user.add_role(:admin);
      puts 'admin created'

      forums = FactoryBot::create_list(:forum, 5, added_by: user)
      puts 'forums created'

      forums.each do |forum|
        topics = FactoryBot::create_list(:topic, 30, forum: forum)
        puts "topics created for a forum"
        topics.each do |topic|
          FactoryBot::create_list(:post, [10, 20, 30].sample, topic: topic)
        end
        puts 'posts created'
      end
    end
  end

end
