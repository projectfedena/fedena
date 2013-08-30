require File.expand_path(File.dirname(__FILE__) + './../test_helper')

class ExamGroupTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_have_many :exams

  context 'a new exam group' do
    setup do
      @exam_group = Factory.build(:exam_group)
    end

    should 'be valid' do
      assert_valid @exam_group
    end

    should 'validate presence of name' do
      @exam_group.name = nil
      assert_invalid @exam_group
    end

    should 'save current date if date is not given' do
      @exam_group.exam_date = nil
      @exam_group.save
      assert (@exam_group.exam_date == Date.today)
    end
  end
end