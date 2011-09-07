require File.expand_path(File.dirname(__FILE__) + './../test_helper')

class CourseTest < ActiveSupport::TestCase

  should_validate_presence_of :course_name, :code
  should_have_many :batches

  should_have_named_scope :active, :conditions => { :is_deleted => false }, :order => 'course_name asc'
  should_have_named_scope :deleted, :conditions => { :is_deleted => true }, :order => 'course_name asc'

  context 'a new course' do
    setup do
      @course = Factory.build(:course)
      @batch = Factory.build(:batch)
      @course.batches << @batch
    end

    should 'at laest have a batch' do
      @course.save
      assert_equal @course.batches.count,1
    end

  end

  context 'existing course' do
    setup do
      @course = Factory.create(:course)
    end

    should 'be inactive' do
      @course.inactivate
      assert @course.is_deleted
    end

  end

end