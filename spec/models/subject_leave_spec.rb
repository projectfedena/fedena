require 'spec_helper'

describe SubjectLeave do

  it { should belong_to(:student) }
  it { should belong_to(:batch) }
  it { should belong_to(:subject) }
  it { should belong_to(:employee) }
  it { should belong_to(:class_timing) }

  it { should validate_presence_of(:subject_id) }
  it { should validate_presence_of(:batch_id) }
  it { should validate_presence_of(:student_id) }
  it { should validate_presence_of(:month_date) }
  it { should validate_presence_of(:reason) }

  context 'a record existed' do
    let!(:subject_leave) { FactoryGirl.create(:subject_leave) }

    it { should validate_uniqueness_of(:student_id).scoped_to(:class_timing_id, :month_date).with_message(/already marked as absent/) }
  end

  describe '#check_attendance_before_the_date_of_admission' do
    let(:student) { FactoryGirl.create(:student, :admission_date => Date.current - 10.days) }
    let(:subject_leave) { FactoryGirl.create(:subject_leave, :student => student) }

    it 'validate that month_date cannot before the date of admission' do
      subject_leave.month_date = Date.current - 10.days
      subject_leave.student.admission_date = Date.current
      subject_leave.should be_invalid
    end
  end

  describe '.by_month_and_subject' do
    let(:student) { FactoryGirl.create(:student, :admission_date => Date.new(2013,7,10)) }
    let!(:subject_leave1) { FactoryGirl.create(:subject_leave, :subject_id => 10, :month_date => Date.new(2013,9,10), :student => student) }
    let!(:subject_leave2) { FactoryGirl.create(:subject_leave, :subject_id => 11, :month_date => Date.new(2013,10,20), :student => student) }

    it 'returns SubjectLeave of month and subject_id' do
      SubjectLeave.by_month_and_subject(Date.new(2013,9,3), subject_leave1.subject_id).should == [subject_leave1]
    end
  end

  describe '.by_month_batch_subject' do
    let(:student) { FactoryGirl.create(:student, :admission_date => Date.new(2013,7,10)) }
    let!(:subject_leave1) { FactoryGirl.create(:subject_leave, :batch_id => 9, :subject_id => 10, :month_date => Date.new(2013,9,10), :student => student) }
    let!(:subject_leave2) { FactoryGirl.create(:subject_leave, :batch_id => 11, :subject_id => 12, :month_date => Date.new(2013,10,20), :student => student) }

    it 'returns SubjectLeave of month, batch_id and subject_id' do
      SubjectLeave.by_month_batch_subject(Date.new(2013,10,3), subject_leave2.batch_id, subject_leave2.subject_id).should == [subject_leave2]
    end
  end

end