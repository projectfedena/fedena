require 'spec_helper'

describe FinanceDonation do

  it { should belong_to(:transaction).class_name('FinanceTransaction').dependent(:destroy) }
  it { should validate_presence_of(:donor) }
  it { should validate_presence_of(:amount) }
  it { should validate_numericality_of(:amount).with_message('must be positive') }

  describe '.validate value of amount' do
    let!(:finance_donation) { FactoryGirl.create(:finance_donation) }

    context 'when amount < 0' do
      before { finance_donation.amount = -1 }

      it 'is invalid' do
        finance_donation.should be_invalid
      end
    end
  end

  describe '#create_finance_transaction' do
    context 'found FinanceTransactionCategory with name Donation' do
      let(:fin_trans_cat) { FinanceTransactionCategory.new }
      before { FinanceTransactionCategory.stub(:find_by_name).with('Donation').and_return(fin_trans_cat) }

      context 'when create finance_donation' do
      let!(:finance_donation) { FactoryGirl.create(:finance_donation, :transaction_id => nil) }

        it 'does update transaction_id with finance_transaction.id' do
          finance_donation.transaction_id.should_not be_nil
        end

        it 'create finance_transaction' do
          FinanceTransaction.all.count.should == 1
        end
      end
    end
  end

end