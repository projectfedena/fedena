require File.expand_path(File.dirname(__FILE__) + './../test_helper')

class CourseTest < ActiveSupport::TestCase

  should_validate_presence_of :course_name
  should_have_many :batches

#  context 'a new course' do
#    setup do
#      @course = Factory.build(:course)
#      @batch = Factory.build(:batch)
#      @course.batches << @batch
#    end
#  end

end