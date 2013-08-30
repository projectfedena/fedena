require 'spec_helper'

describe Batch do
  it { should_have_many :students }
  it { should_have_many :exam_groups }
  it { should_has_many :archived_students }
  it { should_has_many :grading_levels, :conditions => { :is_deleted => false } }
  it { should_has_many :subjects, :conditions => { :is_deleted => false } }
  it { should_has_many :fee_category , :class_name => "FinanceFeeCategory" }
  it { should_has_many :elective_groups }
  it { should_has_many :additional_exam_groups }

  it { should_belong_to :course }

  it { should_validate_presence_of :name }
  it { should_validate_presence_of :start_date }
  it { should_validate_presence_of :end_date }

  context 'a new batch' do
    before do
      @batch = Batch.new(:name => '2009/10')
    end

    it 'does not have start date after end date' do
      @batch.start_date = Date.today
      @batch.end_date = Date.today - 1
      @batch.should_not be_valid
    end

  end
end
