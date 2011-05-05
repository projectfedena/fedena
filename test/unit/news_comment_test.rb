require File.expand_path(File.dirname(__FILE__) + './../test_helper')

class NewsCommentTest < ActiveSupport::TestCase
  should_validate_presence_of :author
  should_validate_presence_of :content
  should_validate_presence_of :news_id
  
  should_belong_to :news
  should_belong_to :author
end
