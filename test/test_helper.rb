ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "./../config/environment")
require File.dirname(__FILE__) + "/factories"  
require 'test_help'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  # fixtures :all

  private
  def assert_invalid(object, msg = nil)
    msg ||= "#{object.class} is valid where it should be invalid."
    assert ! object.valid?, msg
  end
end
