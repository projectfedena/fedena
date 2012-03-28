require 'fedena_plugin'
namespace :fedena do
  namespace :plugins do 
    task :install_all => :environment do
      FedenaPlugin::AVAILABLE_MODULES
      FedenaPlugin::AVAILABLE_MODULES.each do |m|
        Rake::Task["#{m[:name]}:install"].execute
      end
      Rake::Task["db:migrate"].execute
      Rake::Task["db:seed"].execute
      Rake::Task["fedena:plugins:db:migrate"].execute
      Rake::Task["fedena:plugins:db:seed"].execute
    end
  
    namespace :db do

      desc "Migrate the database through scripts in db/migrate and update db/schema.rb by invoking db:schema:dump for each plugin"
      task :migrate => :environment do
        FedenaPlugin::AVAILABLE_MODULES.each do |m|
          ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
          ActiveRecord::Migrator.migrate("vendor/plugins/#{m[:name]}/db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
          Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
        end
      end


      desc 'Load the seed data from db/seeds.rb of each plugin'
      task :seed => :environment do
        FedenaPlugin::AVAILABLE_MODULES.each do |m|
          seed_file = File.join(Rails.root,"vendor/plugins/#{m[:name]}" ,'db', 'seeds.rb')
          load(seed_file) if File.exist?(seed_file)
        end
      end

    end
    
  end 
end
