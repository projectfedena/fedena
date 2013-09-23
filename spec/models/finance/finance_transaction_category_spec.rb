require 'spec_helper'

describe FinanceTransactionCategory do
  let!(:finance_transaction_category) {  FactoryGirl.create(:finance_transaction_category) }

  it { should have_many(:finance_transactions).class_name('FinanceTransaction') }
  it { should have_one(:trigger).class_name('FinanceTransactionTrigger') }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  describe '.income_category_names' do
    subject { FinanceTransactionCategory.income_category_names }
    let(:finance_category) do
      FedenaPlugin::FINANCE_CATEGORY.map do |category|
        category[:category_name]
      end
    end

    it { should include('Fee', 'Salary', 'Donation') }
    it { should include(*finance_category) }
  end

  describe '.income_categories' do
    let(:is_income) { true }
    let(:deleted) { false }
    let(:name) { 'Not in the list' }
    let!(:category) { FactoryGirl.create(:finance_transaction_category, is_income: is_income,
                                                                        deleted: deleted,
                                                                        name: name) }
    subject { FinanceTransactionCategory.income_categories }

    context 'when category is not income' do
      let(:is_income) { false }
      it { should_not include(category) }
    end

    context 'when category name is in the list' do
      let(:name) { 'Fee' }
      it { should_not include(category) }
    end

    context 'when category is not deleted' do
      let(:deleted) { true }
      it { should_not include(category) }
    end

    context 'otherwise' do
      it { should include(category) }
    end
  end

  describe '#fixed?' do
    subject { FactoryGirl.create(:finance_transaction_category, name: name) }

    context 'when category name is not in the list' do
      let(:name) { 'Not in the list' }
      it { should_not be_fixed }
    end

    context 'when category name is in the list' do
      let(:name) { 'Fee' }
      it { should be_fixed }
    end
  end

  describe '#total_income' do
    subject { FactoryGirl.create(:finance_transaction_category, is_income: is_income) }
    let(:start_date) { 2.month.ago }
    let(:end_date) { 1.month.ago }

    context 'when category is not income' do
      let(:is_income) { false }

      it 'returns 0' do
        subject.total_income(start_date, end_date).should == 0
      end
    end

    context 'when category is income' do
      let(:is_income) { true }
      let(:transaction_date) { 40.days.ago }
      let(:master_transaction_id) { 0 }
      let(:amount) { 100 }
      let!(:finance_transaction) do
        FactoryGirl.create(:finance_transaction, transaction_date: transaction_date,
                                                 master_transaction_id: master_transaction_id,
                                                 amount: amount,
                                                 category_id: subject.id)
      end

      context 'when transaction is not in date range' do
        let(:transaction_date) { 10.days.ago }

        it 'does not calculate the sum of that transaction' do
          subject.total_income(start_date, end_date).should == 0
        end
      end

      context 'when master category id is not 0' do
        let(:master_transaction_id) { 1 }

        it 'does not calculate the sum of that transaction' do
          subject.total_income(start_date, end_date).should == 0
        end
      end

      context 'otherwise' do
        it 'calculates the sum of transactions' do
          subject.total_income(start_date, end_date).should == amount
        end
      end
    end
  end

  describe '#total_expense' do
    let(:start_date) { 2.month.ago }
    let(:end_date) { 1.month.ago }
    let(:transaction_date) { 40.days.ago }
    let(:master_transaction_id) { 1 }
    let(:is_income) { true }
    let(:amount) { 100 }
    let(:finance_transaction_category) do
      FactoryGirl.create(:finance_transaction_category, is_income: is_income)
    end
    let!(:finance_transaction) do
      FactoryGirl.create(:finance_transaction, transaction_date: transaction_date,
                                               master_transaction_id: master_transaction_id,
                                               amount: amount,
                                               category_id: finance_transaction_category.id)
    end
    subject { finance_transaction_category.total_expense(start_date, end_date) }

    context 'when transaction is not in date range' do
      let(:transaction_date) { 10.days.ago }
      it { should eql(0) }
    end

    context 'when category is income' do
      let(:is_income) { true }

      context 'when master_transaction_id is not 0' do
        let(:master_transaction_id) { 1 }
        it { should eql(amount) }
      end

      context 'when master_transaction_id is 0' do
        let(:master_transaction_id) { 0 }
        it { should eql(0) }
      end
    end

    context 'when category is not income' do
      let(:is_income) { false }
      it { should eql(amount) }
    end
  end
end
