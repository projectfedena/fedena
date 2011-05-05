require File.join(File.dirname(__FILE__), 'boot')


RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'
  config.gem 'declarative_authorization', :source => 'http://gemcutter.org'
  config.gem 'searchlogic', :version=> '2.4.27'
  config.gem 'prawn', :version=> '0.6.3'
  config.gem 'chronic',:version=> '0.3.0'
  config.gem 'packet', :version=> '0.1.15'

  config.load_once_paths += %W( #{RAILS_ROOT}/lib )
  config.load_paths += Dir["#{RAILS_ROOT}/app/models/*"].find_all { |f| File.stat(f).directory? }
end
