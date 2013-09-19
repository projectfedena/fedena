require 'spec_helper'

describe FinanceFeeCategory do

  it { should belong_to(:batch) }
  #it { should belong_to(:student) }

  it { should have_many(:fee_particulars).class_name('FinanceFeeParticular') }
  #it { should have_many(:fee_collections).class_name('FinanceFeeCollection') }
  it { should have_many(:fee_discounts) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:batch_id).with_message(/not specified/) }

  context 'a exists record' do
    context 'is_deleted is false' do
      subject { FactoryGirl.create(:finance_fee_category, :is_deleted => false) }

      it { should validate_uniqueness_of(:name).scoped_to(:batch_id, :is_deleted) }
    end

    context 'is_deleted is true' do
      subject { FactoryGirl.create(:finance_fee_category, :is_deleted => true) }

      it { should_not validate_uniqueness_of(:name).scoped_to(:batch_id, :is_deleted) }
    end
  end

  describe '#fees' do
    let(:finance_fee_particular) { FinanceFeeParticular.new }
    let(:finance_fee_category) { FactoryGirl.build(:finance_fee_category) }
    let(:student) { FactoryGirl.create(:student) }
    before { FinanceFeeParticular.stub(:find_all_by_finance_fee_category_id).and_return([finance_fee_particular]) }

    it 'returns fees of student' do
      finance_fee_category.fees(student).should == [finance_fee_particular]
    end
  end

  describe '#check_fee_collection' do
    let(:finance_fee_collection) { FinanceFeeCollection.new }
    let(:finance_fee_category) { FactoryGirl.build(:finance_fee_category) }

    context 'fee_collection is not empty' do
      before { FinanceFeeCollection.stub(:find_all_by_fee_category_id).and_return([finance_fee_collection]) }

      it 'is false' do
        finance_fee_category.check_fee_collection.should be_false
      end
    end

    context 'fee_collection is empty' do
      it 'is true' do
        finance_fee_category.check_fee_collection.should be_true
      end
    end
  end

  describe '#check_fee_collection_for_additional_fees' do
    let(:finance_fee_collection) { FinanceFeeCollection.new }
    let(:finance_fee_category) { FactoryGirl.build(:finance_fee_category) }

    context 'fee_collection.check_fee_category = true' do
      before do
        finance_fee_collection.stub(:check_fee_category).and_return(true)
        FinanceFeeCollection.stub(:find_all_by_fee_category_id).and_return([finance_fee_collection])
      end

      it 'is true' do
        finance_fee_category.check_fee_collection_for_additional_fees.should be_true
      end
    end

    context 'fee_collection is nil or fee_collection.check_fee_category = false' do
      it 'is false' do
        finance_fee_category.check_fee_collection_for_additional_fees.should be_false
      end
    end
  end

  describe '#delete_particulars' do
    let(:fee_particulars) { FinanceFeeParticular.new(:is_deleted => false) }
    let(:finance_fee_category) { FactoryGirl.build(:finance_fee_category, :fee_particulars => [fee_particulars]) }

    it 'do update fee_particular.is_deleted to true' do
      finance_fee_category.delete_particulars
      fee_particulars.should be_is_deleted
    end
  end

  describe '#common_active' do
    let(:finance_fee_category) { FactoryGirl.build(:finance_fee_category) }
    before { FinanceFeeCategory.stub(:find).and_return([finance_fee_category]) }

    it 'return common_active of fee category' do
      FinanceFeeCategory.common_active.should == [finance_fee_category]
    end
  end

  describe '#is_collection_open' do
    let(:finance_fee_category) { FactoryGirl.build(:finance_fee_category) }

    context 'found fee_collection and fee_collection.no_transaction_present is false' do
      before do
        finance_fee_category.stub(:no_transaction_present).and_return(false)
        FinanceFeeCollection.stub(:find_all_by_fee_category_id).and_return([finance_fee_category])
      end

      it 'is true' do
        finance_fee_category.is_collection_open.should be_true
      end
    end

    context 'fee_collection is nill' do
      it 'is false' do
        finance_fee_category.is_collection_open.should be_false
      end
    end
  end

  describe '#have_common_particular?' do
    let(:fee_particular) { FinanceFeeParticular.new }
    let(:finance_fee_category) { FactoryGirl.build(:finance_fee_category, :fee_particulars => [fee_particular]) }

    context 'found fee_particulars with student_category_id and admission_no is nil' do
      before { finance_fee_category.fee_particulars.stub(:find_all_by_student_category_id_and_admission_no).with(nil,nil).and_return([fee_particular]) }

      it 'is true' do
        finance_fee_category.have_common_particular?.should be_true
      end
    end

    context 'not found fee_particulars with student_category_id and admission_no is nil' do
      it 'is false' do
        finance_fee_category.have_common_particular?.should be_false
      end
    end
  end

  describe '#student_fee_balance' do
    before do
      @date = FinanceFeeCollection.new
      @student = FactoryGirl.create(:student)
      @fee_category = FactoryGirl.build(:finance_fee_category, :student => @student)

      @finance_fee = FinanceFee.new
      @student.stub(:finance_fee_by_date).and_return(@finance_fee)

      @batch_discounts = BatchFeeDiscount.new(:discount => 10)
      BatchFeeDiscount.stub(:find_all_by_finance_fee_category_id).and_return([@batch_discounts])

      @student_discounts = StudentFeeDiscount.new(:discount => 15)
      StudentFeeDiscount.stub(:find_all_by_finance_fee_category_id_and_receiver_id).and_return([@student_discounts])

      @category_discounts = StudentCategoryFeeDiscount.new(:discount => 20)
      StudentCategoryFeeDiscount.stub(:find_all_by_finance_fee_category_id).and_return([@category_discounts])
    end

    context 'fee_particular is empty' do
      it 'returns total_fee = 0' do
        @fee_category.student_fee_balance(@student, @date).should == 0
      end
    end

    context 'fee_particular is not empty' do
      before do
        @fee_particular = FinanceFeeParticular.new(:amount => 10)
        FinanceFeeParticular.stub(:find_all_by_finance_fee_category_id).and_return([@fee_particular])
      end

      context 'paid_fees is empty' do
        it 'returns total_fee' do
          @fee_category.student_fee_balance(@student, @date).should == 5.5
        end
      end

      context 'paid_fees is not empty' do
        before do
          @student.finance_fee_by_date.transaction_id = 5
          @paid_fees = FinanceTransaction.new(:amount => 4)
          FinanceTransaction.stub(:find).with(:all, :conditions => ["FIND_IN_SET(id, ?)", @finance_fee.transaction_id]).and_return([@paid_fees])
        end

        context 'found finance_transaction' do
          before do
            @finance_transaction = FinanceTransaction.new(:fine_amount => 8,:fine_included => true)
            FinanceTransaction.stub(:find).with(@student.finance_fee_by_date.transaction_id).and_return(@finance_transaction)
          end

          it 'returns total_fee' do
            @fee_category.student_fee_balance(@student, @date).should == 9.5
          end
        end

        context 'not found finance_transaction' do
          before { FinanceTransaction.stub(:find).with(@student.finance_fee_by_date.transaction_id).and_return(nil) }

          it 'returns total_fee' do
            @fee_category.student_fee_balance(@student, @date).should == 1.5
          end
        end
      end
    end
  end
end
