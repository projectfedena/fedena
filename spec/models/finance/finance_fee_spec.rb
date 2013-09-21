require 'spec_helper'

describe FinanceFee do

  it { should belong_to(:finance_fee_collection) }
  it { should belong_to(:student) }
  it { should have_many(:finance_transactions) }
  #it { should have_many(:components).class_name('FinanceFeeComponent') }

  describe '#check_transaction_done' do
    context 'transaction_id is present' do
      let(:finance_fee) { FinanceFee.create(:transaction_id => 5) }

      it 'returns true' do
        finance_fee.check_transaction_done.should be_true
      end
    end

    context 'transaction_id is nil' do
      let(:finance_fee) { FinanceFee.create(:transaction_id => nil) }

      it 'returns false' do
        finance_fee.check_transaction_done.should be_false
      end
    end
  end

  describe '#former_student' do
    let(:finance_fee) { FinanceFee.create(:student_id => 5) }

    context 'found ArchivedStudent with student_id' do
      let(:archived_student) { ArchivedStudent.new }
      before { ArchivedStudent.stub(:find_by_former_id).with(5).and_return(archived_student) }

      it 'returns archived_student' do
        finance_fee.former_student.should == archived_student
      end
    end
  end
end