require 'spec_helper'

describe Batch do
  it { should have_many(:students) }
  it { should have_many(:exam_groups) }
  it { should have_many(:archived_students) }
  it { should have_many(:grading_levels).conditions(:is_deleted => false) }
  it { should have_many(:subjects).conditions(:is_deleted => false) }
  it { should have_many(:fee_category).class_name("FinanceFeeCategory") }
  it { should have_many(:elective_groups) }
  it { should have_many(:grouped_exam_reports) }
  it { should have_many(:grouped_batches) }
  it { should have_many(:finance_fee_collections) }
  it { should have_many(:finance_transactions).through(:students) }
  it { should have_many(:batch_events) }
  it { should have_many(:events).through(:batch_events) }
  it { should have_many(:batch_fee_discounts) }
  it { should have_many(:student_category_fee_discounts) }
  it { should have_many(:attendances) }
  it { should have_many(:subject_leaves) }
  it { should have_many(:timetable_entries) }
  it { should have_many(:cce_reports) }
  it { should have_many(:assessment_scores) }

  it { should belong_to(:course) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:started_on) }
  it { should validate_presence_of(:ended_on) }

  context 'a new batch' do
    before do
      @batch = Batch.new(:name => '2009/10')
    end

    it 'does not have start date after end date' do

      @batch.started_on = Date.today
      @batch.ended_on = Date.today - 1
      @batch.should_not be_valid
    end

  end
end
