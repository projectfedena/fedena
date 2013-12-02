require 'spec_helper'

describe BatchFeeCollectionDiscount do

  it { should belong_to(:receiver).class_name('Batch') }
  it { should belong_to(:finance_fee_collection) }
  it { should validate_presence_of(:receiver_id).with_message(/Batch cant be blank/) }

  describe '#total_payable' do
    let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
    let(:batch_fee_collect_discount) { BatchFeeCollectionDiscount.new(:finance_fee_collection => finance_fee_collection) }

    context 'with argument student' do
      let(:student) { FactoryGirl.build(:student) }
      let(:fee_collect_particular1) { FeeCollectionParticular.new(:amount => 10) }
      let(:fee_collect_particular2) { FeeCollectionParticular.new(:amount => 7) }
      before { finance_fee_collection.stub(:fees_particulars).with(student).and_return([fee_collect_particular1, fee_collect_particular2]) }

      it 'returns sum of fees_particulars' do
        batch_fee_collect_discount.total_payable(student).should == 17
      end
    end

    context 'with no argument' do
      let(:finance_fee_particular1) { FinanceFeeParticular.new(:amount => 15) }
      let(:finance_fee_particular2) { FinanceFeeParticular.new(:amount => 12) }
      let(:finance_fee_category) { FinanceFeeCategory.new }
      before do
        finance_fee_collection.fee_category = finance_fee_category
        finance_fee_category.fee_particulars.stub(:active).and_return([finance_fee_particular1, finance_fee_particular2])
      end

      it 'returns sum of active fees_particulars' do
        batch_fee_collect_discount.total_payable.should == 27
      end
    end
  end

  describe '#discount' do
    let(:batch_fee_collect_discount) { BatchFeeCollectionDiscount.new(:discount => 15) }

    context 'with argument student' do
      let(:student) { FactoryGirl.build(:student) }
      before { batch_fee_collect_discount.stub(:total_payable).with(student).and_return(25) }

      context 'is_amount? is true' do
        before { batch_fee_collect_discount.is_amount = true }

        it 'return percent' do
          batch_fee_collect_discount.discount(student).should == 60
        end
      end

      context 'is_amount? is false' do
        before { batch_fee_collect_discount.is_amount = false }

        it 'return discount' do
          batch_fee_collect_discount.discount(student).should == 15
        end
      end
    end

    context 'with no argument' do
      before { batch_fee_collect_discount.stub(:total_payable).and_return(25) }

      context 'is_amount? is true' do
        before { batch_fee_collect_discount.is_amount = true }

        it 'return percent' do
          batch_fee_collect_discount.discount.should == 60
        end
      end

      context 'is_amount? is false' do
        before { batch_fee_collect_discount.is_amount = false }

        it 'return discount' do
          batch_fee_collect_discount.discount.should == 15
        end
      end
    end
  end
end