$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
plugin_test_dir = File.dirname(__FILE__)

#require 'multi_rails_init'
require 'active_record'
# Workaround for https://rails.lighthouseapp.com/projects/8994/tickets/2577-when-using-activerecordassociations-outside-of-rails-a-nameerror-is-thrown
ActiveRecord::ActiveRecordError

require plugin_test_dir + '/../init.rb'

ActiveRecord::Base.logger = Logger.new(plugin_test_dir + "/test.log")

ActiveRecord::Base.configurations = YAML::load(IO.read(plugin_test_dir + "/db/database.yml"))
ActiveRecord::Base.establish_connection(ENV["DB"] || "sqlite3")
ActiveRecord::Migration.verbose = false
load(File.join(plugin_test_dir, "db", "schema.rb"))

Dir["#{plugin_test_dir}/models/*.rb"].each {|file| require file }

Spec::Runner.configure do |config|
  config.before do
  end
end
