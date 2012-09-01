#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

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
