require 'spec_helper'

describe StudentFeeCollectionDiscount do

  it { should belong_to(:receiver).class_name('Student') }
  it { should validate_presence_of(:receiver_id).with_message(/Student Admission number cant be blank/) }

  describe '#student_name' do
    let(:student_fee_collect_discount) { StudentFeeCollectionDiscount.new }

    context 'found student with receiver_id' do
      let(:student) { FactoryGirl.build(:student, :first_name => 'Student', :admission_no => 10) }
      before { Student.stub(:find).and_return(student) }

      it 'returns first_name and admission_no of student' do
        student_fee_collect_discount.student_name.should == 'Student (10)'
      end
    end
  end
end