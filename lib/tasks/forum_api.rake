require 'factory_bot'
namespace :forum_api do
  desc "TODO"
  task create_dummy_data: :environment do
    User.transaction do
      users = FactoryBot.create_list(:admin, 3)
      puts 'admins created'

      forums = users.collect{|user| FactoryBot.create_list(:forum, 5, added_by: user) }.flatten
      puts 'forums created'

      forums.each do |forum|
        topics = FactoryBot.create_list(:topic, 30, forum: forum, added_by: users.sample)
        puts "topics created for a forum"
        topics.each do |topic|
          FactoryBot.create_list(:post, [10, 20, 30].sample, topic: topic, added_by: users.sample)
        end
        puts 'posts created'
      end
    end
  end

end
