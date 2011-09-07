require File.expand_path(File.dirname(__FILE__) + './../test_helper')

class SubjectTest < ActiveSupport::TestCase

  should_validate_presence_of :name,:code,:max_weekly_classes,:batch_id
  should_validate_numericality_of :max_weekly_classes
  should_belong_to :batch
  should_belong_to :elective_group
  should_have_many :timetable_entries
  should_have_many :employees_subjects
  
  context 'new general subject' do

    setup do
      @subject = Factory.build(:general_subject)
    end

    should 'be a new record' do
      assert @subject.new_record?
    end

    should 'create a subject without exam' do
      @subject.batch_id = 1
      @subject.no_exams = true
      assert_valid @subject
    end

    should 'not create a subject with same code' do
      @subject = Factory.create(:general_subject)
      @subject2 = Factory.build(:general_subject)
      assert_invalid @subject2
      assert @subject2.errors.invalid?(:code)
    end

    should 'save with valid data' do
      @subject = Factory.build(:general_subject)
      @subject.save
      assert_equal Subject.count, 1
    end

    should 'be disabled' do
      @subject.inactivate
      assert @subject.is_deleted
    end

  end

end