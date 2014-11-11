require 'spec_helper'

describe FinanceFeeCollection do
  it { should belong_to(:batch) }
  it { should belong_to(:fee_category).class_name('FinanceFeeCategory') }

  it { should have_many(:finance_fees).dependent(:destroy) }
  it { should have_many(:finance_transactions).through(:finance_fees) }
  it { should have_many(:students).through(:finance_fees) }
  it { should have_many(:fee_collection_particulars).dependent(:destroy) }
  it { should have_many(:fee_collection_discounts).dependent(:destroy) }
  it { should have_one(:event) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:fee_category_id) }
  it { should validate_presence_of(:end_date) }
  it { should validate_presence_of(:due_date) }

  describe '#create_associates' do
    context 'fee_discounts and fee_particular are found' do
      before do
        @finance_fee_category = FactoryGirl.create(:finance_fee_category)
        @finance_fee_collection = FactoryGirl.build(:finance_fee_collection,
          :fee_category => @finance_fee_category)
        FactoryGirl.create(:batch_fee_discount,
          :finance_fee_category_id => @finance_fee_category.id)
        FactoryGirl.create(:student_category_fee_discount,
          :finance_fee_category_id => @finance_fee_category.id)
        FactoryGirl.create(:student_fee_discount,
          :finance_fee_category_id => @finance_fee_category.id)
        FactoryGirl.create(:finance_fee_particular,
          :finance_fee_category_id => @finance_fee_category.id)
      end

      it 'create fee collection discounts' do
        @finance_fee_collection.save
        BatchFeeCollectionDiscount.all.count.should == 1
        StudentCategoryFeeCollectionDiscount.all.count.should == 1
        StudentFeeCollectionDiscount.all.count.should == 1
        FeeCollectionParticular.all.count.should == 1
      end
    end

    context 'fee_discounts and fee_particular are not found' do
      let(:finance_fee_collection) { FactoryGirl.build(:finance_fee_collection) }

      it 'do not create fee collection discounts' do
        finance_fee_collection.save
        BatchFeeCollectionDiscount.all.count.should == 0
        StudentCategoryFeeCollectionDiscount.all.count.should == 0
        StudentFeeCollectionDiscount.all.count.should == 0
        FeeCollectionParticular.all.count.should == 0
      end
    end
  end

  describe '#valid_date' do
    context 'start_date is after end_date' do
      let(:finance_fee_collection) { FactoryGirl.build(:finance_fee_collection, :start_date => Date.current + 5.days) }

      it 'returns errors' do
        finance_fee_collection.should be_invalid
        finance_fee_collection.errors[:base].should == I18n.t('start_date_cant_be_after_end_date')
      end
    end

    context 'start_date is after due_date' do
      let(:finance_fee_collection) { FactoryGirl.build(:finance_fee_collection, :start_date => Date.current + 10.days) }

      it 'returns errors' do
        finance_fee_collection.should be_invalid
        finance_fee_collection.errors[:base].should include(I18n.t('start_date_cant_be_after_due_date'))
      end
    end

    context 'end_date is after due_date' do
      let(:finance_fee_collection) { FactoryGirl.build(:finance_fee_collection, :end_date => Date.current + 10.days) }

      it 'returns errors' do
        finance_fee_collection.should be_invalid
        finance_fee_collection.errors[:base].should == I18n.t('end_date_cant_be_after_due_date')
      end
    end
  end

  describe '#full_name' do
    let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }

    it 'returns full_name' do
      fullname = finance_fee_collection.name + ' - ' + finance_fee_collection.start_date.to_s
      finance_fee_collection.full_name.should == fullname
    end
  end

  describe '#fee_transactions' do
    let(:student) { FactoryGirl.create(:student) }
    let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
    let!(:finance_fee) { FactoryGirl.create(:finance_fee,
      :finance_fee_collection => finance_fee_collection,
      :student => student) }

    it 'returns fee_transactions' do
      finance_fee_collection.fee_transactions(student.id).should == finance_fee
    end
  end

  describe '#check_transaction' do
    context 'finance_fee_id is not nil' do
      let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
      let!(:finance_transaction) { FactoryGirl.create(:finance_transaction, :finance_fees_id => 1) }

      it 'returns true' do
        finance_fee_collection.check_transaction(finance_transaction).should be_true
      end
    end

    context 'finance_fee_id is nil' do
      let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
      let!(:finance_transaction) { FactoryGirl.create(:finance_transaction, :finance_fees_id => '') }

      it 'returns false' do
        finance_fee_collection.check_transaction(finance_transaction).should be_false
      end
    end
  end

  describe '#fee_table' do
    let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
    let!(:finance_fee) { FactoryGirl.create(:finance_fee,
      :finance_fee_collection => finance_fee_collection) }

    it 'returns fee_table' do
      finance_fee_collection.fee_table.should == [finance_fee]
    end
  end

  describe '.shorten_string' do
    context 'string length >= count' do
      it 'returns shortened string' do
        FinanceFeeCollection.shorten_string('This is a string 12345', 20).should == 'This is a string ...'
      end
    end

    context 'string length < count' do
      it 'returns string' do
        FinanceFeeCollection.shorten_string('This is a string 12345', 30).should == 'This is a string 12345'
      end
    end
  end

  describe '#check_fee_category' do
    context 'fee_category is found' do
      let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
      let!(:finance_fee) { FactoryGirl.create(:finance_fee,
        :finance_fee_collection => finance_fee_collection) }

      it 'returns true' do
        finance_fee_collection.check_fee_category.should be_true
      end
    end

    context 'fee_category is not found' do
      let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
      let!(:finance_fee) { FactoryGirl.create(:finance_fee,
        :finance_fee_collection => finance_fee_collection,
        :transaction_id => '123') }

      it 'returns false' do
        finance_fee_collection.check_fee_category.should be_false
      end
    end
  end

  describe '#no_transaction_present' do
    context 'transaction is not exist' do
      let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
      let!(:finance_fee) { FactoryGirl.create(:finance_fee,
        :finance_fee_collection => finance_fee_collection) }

      it 'returns true' do
        finance_fee_collection.no_transaction_present.should be_true
      end
    end

    context 'transaction is exist' do
      let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
      let!(:finance_fee) { FactoryGirl.create(:finance_fee,
        :finance_fee_collection => finance_fee_collection,
        :transaction_id => '123') }

      it 'returns false' do
        finance_fee_collection.no_transaction_present.should be_false
      end
    end
  end

  describe '#fees_particulars' do
    context 'student_category_id is null and admission_no is null' do
      let(:student) { FactoryGirl.create(:student) }
      let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
      let!(:fee_collection_particular) { FactoryGirl.create(:fee_collection_particular,
        :finance_fee_collection => finance_fee_collection,
        :student_category_id => nil,
        :admission_no => nil) }

      it 'returns fees_particulars' do
        finance_fee_collection.fees_particulars(student).should == [fee_collection_particular]
      end
    end

    context 'student_category_id and admission_no is null' do
      let(:student) { FactoryGirl.create(:student, :student_category_id => 1) }
      let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
      let!(:fee_collection_particular) { FactoryGirl.create(:fee_collection_particular,
        :finance_fee_collection => finance_fee_collection,
        :student_category_id => 1,
        :admission_no => nil) }

      it 'returns fees_particulars' do
        finance_fee_collection.fees_particulars(student).should == [fee_collection_particular]
      end
    end

    context 'student_category_id is null and admission_no' do
      let(:student) { FactoryGirl.create(:student, :admission_no => 'A2') }
      let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
      let!(:fee_collection_particular) { FactoryGirl.create(:fee_collection_particular,
        :finance_fee_collection => finance_fee_collection,
        :student_category_id => nil,
        :admission_no => 'A2') }

      it 'returns fees_particulars' do
        finance_fee_collection.fees_particulars(student).should == [fee_collection_particular]
      end
    end

    context 'is_deleted?' do
      let(:student) { FactoryGirl.create(:student, :admission_no => 'A2') }
      let(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
      let!(:fee_collection_particular) { FactoryGirl.create(:fee_collection_particular,
        :finance_fee_collection => finance_fee_collection,
        :is_deleted => true) }

      it 'returns nil' do
        finance_fee_collection.fees_particulars(student).should == []
      end
    end
  end

  describe '#transaction_total' do
    let!(:finance_fee_collection) { FactoryGirl.create(:finance_fee_collection) }
    let!(:finance_fee) { FactoryGirl.create(:finance_fee,
      :finance_fee_collection => finance_fee_collection) }

    context 'valid finance_transaction' do
      before do
        FactoryGirl.create(:finance_transaction, :finance => finance_fee, :amount => 100)
        FactoryGirl.create(:finance_transaction, :finance => finance_fee, :amount => 80)
        FactoryGirl.create(:finance_transaction, :finance => finance_fee,
          :amount => 20, :transaction_date => Date.current + 5.days)
      end

      it 'returns transaction_total' do
        finance_fee_collection.transaction_total(Date.current - 3.days, Date.current + 3.days).should == 180
      end
    end
  end

  describe '#student_fee_balance' do
    before do
      @student = Student.create(:admission_no => '123', :admission_date => Date.today, :first_name => 'abc213', :batch_id => '321', :date_of_birth => Date.today - 10.years, :gender => 'm', :student_category_id => 1)
      @finance_fee_collection = FactoryGirl.create(:finance_fee_collection)
      @finance_transaction = FactoryGirl.create(:finance_transaction, :amount => 20)
      @finance_fee = FactoryGirl.create(:finance_fee,
        :finance_fee_collection => @finance_fee_collection,
        :student => @student,
        :transaction_id => @finance_transaction.id)
      FactoryGirl.create(:fee_collection_particular,
        :finance_fee_collection => @finance_fee_collection,
        :amount => 68)
      FactoryGirl.create(:fee_collection_particular,
        :finance_fee_collection => @finance_fee_collection,
        :amount => 72)
      FactoryGirl.create(:batch_fee_collection_discount,
        :finance_fee_collection_id => @finance_fee_collection.id,
        :discount => 10)
      FactoryGirl.create(:student_fee_collection_discount,
        :finance_fee_collection_id => @finance_fee_collection.id,
        :receiver_id => @student.id,
        :discount => 20)
      FactoryGirl.create(:student_category_fee_collection_discount,
        :finance_fee_collection_id => @finance_fee_collection.id,
        :receiver_id => @student.student_category_id,
        :discount => 12)
    end

    it 'returns student_fee_balance' do
      @finance_fee_collection.student_fee_balance(@student.id).should == 61.2
    end
  end
end