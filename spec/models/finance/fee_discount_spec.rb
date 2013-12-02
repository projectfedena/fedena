require 'spec_helper'

describe FeeDiscount do

  it { should belong_to(:finance_fee_category) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:discount) }
  it { should validate_presence_of(:type) }
  it { should validate_numericality_of(:discount) }

  describe '#discount_must_be_between_0_to_100' do
    context 'is_amount? is false' do
      let(:fee_discount) { FactoryGirl.create(:fee_discount, :is_amount => false) }

      context 'discount must be between 0 to 100' do
        it 'is invalid' do
          fee_discount.discount = 102
          fee_discount.should be_invalid
        end
      end
    end
  end

  describe '#discount_cannot_be_greater_than_total_payable_amount' do
    context 'is_amount? is true' do
      let(:fee_particular) { FinanceFeeParticular.new(:amount => 80) }
      let(:finance_fee_category) { FinanceFeeCategory.new(:fee_particulars => [fee_particular]) }
      let(:fee_discount) { FactoryGirl.create(:fee_discount, :is_amount => true, :finance_fee_category => finance_fee_category) }

      context 'discount cannot be greater than total payable amount' do
        it 'is invalid' do
          fee_discount.discount = 85
          fee_discount.should be_invalid
        end
      end
    end
  end

  describe '#total_payable' do
    let(:fee_particular1) { FinanceFeeParticular.new(:amount => 80) }
    let(:fee_particular2) { FinanceFeeParticular.new(:amount => 40) }
    let(:finance_fee_category) { FinanceFeeCategory.new(:fee_particulars => [fee_particular1, fee_particular2]) }
    let(:fee_discount) { FactoryGirl.build(:fee_discount, :finance_fee_category => finance_fee_category) }

    it 'returns sum of fee_particulars' do
      fee_discount.total_payable.should == 120
    end
  end

  describe '#discount' do
    before do
      @fee_discount = FactoryGirl.build(:fee_discount, :discount => 16)
      @fee_discount.stub(:total_payable).and_return(80)
    end

    context 'is_amount is true' do
      before { @fee_discount.is_amount = true }

      it 'returns discount percent' do
        @fee_discount.discount.should == 20
      end
    end

    context 'is_amount is false' do
      before { @fee_discount.is_amount = false }

      it 'returns discount' do
        @fee_discount.discount.should == 16
      end
    end
  end

  describe '#category_name' do
    let(:fee_discount) { FactoryGirl.build(:fee_discount) }

    context 'found StudentCategory' do
      before do
        student_cat = StudentCategory.new(:name => 'Student Cat Name')
        StudentCategory.stub(:find).and_return(student_cat)
      end

      it 'returns name of StudentCategory' do
        fee_discount.category_name.should == 'Student Cat Name'
      end
    end
  end

  describe '#student_name' do
    let(:fee_discount) { FactoryGirl.build(:fee_discount) }

    context 'found Student' do
      before do
        student = Student.new(:first_name => 'Student FN', :admission_no => '10')
        Student.stub(:find).and_return(student)
      end

      it 'returns first_name and admission_no' do
        fee_discount.student_name.should == 'Student FN (10)'
      end
    end
  end
end
