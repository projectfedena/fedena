require File.expand_path(File.dirname(__FILE__) + './../test_helper')

class BatchTest < ActiveSupport::TestCase
  should_have_many :students
  should_have_many :exam_groups
  should_belong_to :course

  should_validate_presence_of :name
  should_validate_presence_of :start_date
  should_validate_presence_of :end_date

  context 'a new batch' do
    setup do
      @batch = Batch.new(:name => '2009/10')
    end

    should 'not have start date after end date' do
      @batch.start_date = Date.today
      @batch.end_date = Date.today - 1
      assert ! @batch.valid?
    end

  end

end