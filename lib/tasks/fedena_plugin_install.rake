require 'fedena_plugin'
namespace :fedena do
 namespace :plugins do 
  task :install_all => :environment do
    FedenaPlugin::AVAILABLE_MODULES
    FedenaPlugin::AVAILABLE_MODULES.each do |m|
       Rake::Task["#{m[:name]}:install"].execute
    end
   Rake::Task["db:migrate"].execute
  end
 end 
end
