ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_support/test_case'


def load_schema
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/db/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
  ActiveRecord::Base.establish_connection(config['test'])
  load(File.dirname(__FILE__) + "/db/schema.rb")
  require File.dirname(__FILE__) + '/../init.rb'
end
