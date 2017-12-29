require 'factory_bot'
namespace :forum_api do
  desc "TODO"
  task create_dummy_data: :environment do
    User.transaction do
      user = FactoryBot::create(:user)
      user.add_role(:admin);
      puts 'admin created'

      forums = FactoryBot::create_list(:forum, 20, added_by: user)
      puts 'forums created'

      forums.each do |forum|
        FactoryBot::create_list(:topic, 50, forum: forum)
      end
      puts 'topics created'
    end
  end

end
