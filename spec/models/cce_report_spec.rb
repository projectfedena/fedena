require 'spec_helper'

describe CceReport do
  it { should belong_to(:batch) }
  it { should belong_to(:student) }
  it { should belong_to(:observable) }
  it { should belong_to(:exam) }

  describe '.find_student' do
    let(:student_id) { 10 }
    let!(:archived_student) { create(:archived_student, id: student_id) }
    let!(:student) { create(:student, id: student_id) }
    subject { CceReport.find_student(type, student_id) }

    context 'type is former' do
      let(:type) { 'former' }
      it { should eql(archived_student) }
    end

    context 'type is not former' do
      let(:type) { 'not_former' }
      it { should eql(student) }
    end
  end
end
