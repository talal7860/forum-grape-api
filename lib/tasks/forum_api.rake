require 'factory_bot'
namespace :forum_api do
  desc "TODO"
  task create_dummy_data: :environment do
    FactoryBot::create_list(:forum, 20)
    puts 'forums created'
  end

end
