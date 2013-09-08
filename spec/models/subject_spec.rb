require 'spec_helper'

describe Subject do

  before { @subject = Factory.create(:general_subject) }

  it { should belong_to(:batch) }
  it { should belong_to(:elective_group) }
  it { should have_many(:timetable_entries) }
  it { should have_many(:employees_subjects) }
  it { should have_many(:employees).through(:employees_subjects) }
  it { should have_many(:students_subjects) }
  it { should have_many(:students).through(:students_subjects) }
  it { should have_many(:grouped_exam_reports) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:max_weekly_classes) }
  it { should validate_presence_of(:batch_id) }
  it { should validate_presence_of(:credit_hours) if @subject.check_grade_type }
  it { should validate_numericality_of(:max_weekly_classes) }
  it { should validate_numericality_of(:amount) }
  it { should validate_uniqueness_of(:code).scoped_to(:batch_id,:is_deleted) unless @subject.is_deleted }

  describe '#inactivate' do
    it 'set is_deleted true' do
      @subject.inactivate
      @subject.should be_is_deleted
    end
  end

end