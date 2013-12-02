require 'spec_helper'

describe FinanceFeeParticular do

  it { should belong_to(:finance_fee_category) }
  it { should belong_to(:student_category) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount).with_message(/must be positive/) }

  describe '.active' do
    let!(:fee_particular1) { FactoryGirl.create(:finance_fee_particular, :is_deleted => false) }
    let!(:fee_particular2) { FactoryGirl.create(:finance_fee_particular, :is_deleted => true) }

    it 'returns active student category' do
      active_fee_particular = FinanceFeeParticular.active
      active_fee_particular.count.should == 1
      active_fee_particular.should include(fee_particular1)
    end
  end

  describe '#deleted_category' do
    context 'student_category.is_deleted is true' do
      let(:student_category) { FactoryGirl.create(:student_category, :is_deleted => true ) }
      let!(:fee_particular) { FactoryGirl.create(:finance_fee_particular, :student_category => student_category) }

      it 'returns true' do
        fee_particular.deleted_category.should be_true
      end
    end

    context 'student_category is nil' do
      let!(:fee_particular) { FactoryGirl.create(:finance_fee_particular, :student_category => nil) }

      it 'returns false' do
        fee_particular.deleted_category.should be_false
      end
    end
  end
end