require 'spec_helper'

describe StudentsSubject do
  it { should belong_to(:student) }
  it { should belong_to(:subject) }

  describe '#student_assigned' do
    before do
      @student         = FactoryGirl.create(:student)
      @batch           = FactoryGirl.create(:batch)
      @subject         = FactoryGirl.create(:subject, :batch_id => @batch.id)
      @student_subject = StudentsSubject.create(:student_id => @student.id, :subject_id => @subject.id, :batch_id => @batch.id)
    end

    it 'returns student subject' do
      @student_subject.student_assigned(@student, @subject).should == @student_subject
    end
  end
end