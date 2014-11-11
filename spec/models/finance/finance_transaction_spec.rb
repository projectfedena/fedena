require 'spec_helper'

describe FinanceTransaction do
  it { should belong_to(:category).class_name('FinanceTransactionCategory') }
  it { should belong_to(:student) }
  it { should belong_to(:finance) }
  it { should belong_to(:payee) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:transaction_date) }
  it { should validate_presence_of(:category).with_message(I18n.t('not_specified')) }
  it { should validate_numericality_of(:amount).with_message(I18n.t('must_be_positive')) }

  let(:start_date) { Date.current - 3.days }
  let(:end_date)   { Date.current + 3.days }

  describe '.report' do
    context 'FinanceTransaction is found' do
      let(:fina_tran_category) { FactoryGirl.create(:finance_transaction_category, :name => 'Cat1') }
      let!(:finance_transaction) { FactoryGirl.create(:finance_transaction, :category => fina_tran_category) }
      before { FactoryGirl.create(:finance_transaction_category, :name => 'Salary') }

      it 'returns report' do
        FinanceTransaction.report(start_date, end_date, 1).should == [finance_transaction]
      end
    end

    context 'FinanceTransaction is not found' do
      let(:fina_tran_category) { FactoryGirl.create(:finance_transaction_category, :name => 'Fee') }
      let!(:finance_transaction) { FactoryGirl.create(:finance_transaction, :category => fina_tran_category) }

      it 'returns report' do
        FinanceTransaction.report(start_date, end_date, 1).should == []
      end
    end
  end

  describe '.grand_total' do
    context 'HR is nil' do
      before do 
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Cat1'))
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Fee'),
          :amount => 68)
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Donation'),
          :amount => 72)
      end

      it 'returns grand_total' do
        FinanceTransaction.grand_total(start_date, end_date).should == 40
      end
    end

    context 'HR is not nil' do
      before do 
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Cat1'),
          :amount => 18)
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Fee'),
          :amount => 68)
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Donation'),
          :amount => 72)
        Configuration.create(:config_value => "HR")

        FactoryGirl.create(:monthly_payslip, 
          :amount => 25,
          :is_approved => true,
          :employee => FactoryGirl.create(:employee),
          :payroll_category => PayrollCategory.create(:name => 'PCat1'))
      end

      it 'returns grand_total' do
        FinanceTransaction.grand_total(start_date, end_date).should == 97
      end
    end
  end

  describe '.total_fees' do
    let(:fin_tran_cat) { FactoryGirl.create(:finance_transaction_category, :name => 'Fee') }

    context 'FinanceTransaction is found' do
      before do
        FactoryGirl.create(:finance_transaction, :category => fin_tran_cat, :amount => 68)
        FactoryGirl.create(:finance_transaction, :category => fin_tran_cat, :amount => 30)
      end

      it 'returns total_fees' do
        FinanceTransaction.total_fees(start_date, end_date).should == 98
      end
    end

    context 'FinanceTransaction has not valid dates' do
      before { FactoryGirl.create(:finance_transaction, :category => fin_tran_cat, :amount => 68) }

      it 'returns total_fees' do
        FinanceTransaction.total_fees(start_date, Date.current - 2.days).should == 0
      end
    end
  end

  describe '.total_other_trans' do
    context 'income and expense are valid' do
      before do
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Cat1', :is_income => true),
          :amount => 18)
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Cat2', :is_income => false),
          :amount => 68)
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Fee'),
          :amount => 20)
      end

      it 'returns total_other_trans' do
        FinanceTransaction.total_other_trans(start_date, end_date).should == [18, 68]
      end
    end

    context 'income is nil and expense is valid' do
      before do
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Cat1', :is_income => false),
          :amount => 18)
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Cat2', :is_income => false),
          :amount => 68)
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Fee'),
          :amount => 20)
      end

      it 'returns total_other_trans' do
        FinanceTransaction.total_other_trans(start_date, end_date).should == [0, 86]
      end
    end
  end

  describe '.donations_triggers' do
    context 'donation category is found' do
      before do
        @fin_tran_cat = FactoryGirl.create(:finance_transaction_category, :name => 'Donation', :is_income => true)
        FactoryGirl.create(:finance_transaction,
          :category => @fin_tran_cat,
          :amount => 62,
          :master_transaction_id => 0)
        FactoryGirl.create(:finance_transaction,
          :category => @fin_tran_cat,
          :amount => 20,
          :master_transaction_id => 1)
      end

      it 'returns donations_triggers' do
        FinanceTransaction.donations_triggers(start_date, end_date).should == 42
      end
    end

    context 'donation category is not found' do
      before do
        FactoryGirl.create(:finance_transaction,
          :category => FactoryGirl.create(:finance_transaction_category, :name => 'Fee'),
          :amount => 20)
      end

      it 'returns donations_triggers' do
        FinanceTransaction.donations_triggers(start_date, end_date).should == 0
      end
    end
  end

  describe '.expenses' do
    context 'expenses is found' do
      let!(:fin_tran) { FactoryGirl.create(:finance_transaction,
        :category => FactoryGirl.create(:finance_transaction_category, :id => 123, :is_income => false)) }
      before { FactoryGirl.create(:finance_transaction,
        :category => FactoryGirl.create(:finance_transaction_category, :id => 1, :is_income => true)) }

      it 'returns expenses' do
        FinanceTransaction.expenses(start_date, end_date).should == [fin_tran]
      end
    end

    context 'expenses is not found' do
      let!(:fin_tran) { FactoryGirl.create(:finance_transaction,
        :category => FactoryGirl.create(:finance_transaction_category, :id => 1, :is_income => true)) }

      it 'returns expenses' do
        FinanceTransaction.expenses(start_date, end_date).should == []
      end
    end
  end

  describe '.incomes' do
    before do
      FactoryGirl.create(:finance_transaction,
      :category => FactoryGirl.create(:finance_transaction_category, :name => 'Fee', :is_income => true))
      FactoryGirl.create(:finance_transaction,
      :category => FactoryGirl.create(:finance_transaction_category, :is_income => true),
      :master_transaction_id => 2)
    end

    context 'valid incomes' do
      let!(:fin_tran) { FactoryGirl.create(:finance_transaction,
        :category => FactoryGirl.create(:finance_transaction_category, :is_income => true)) }

      it 'returns incomes' do
        FinanceTransaction.incomes(start_date, end_date).should == [fin_tran]
      end
    end

    context 'invalid incomes' do
      before { FactoryGirl.create(:finance_transaction,
        :category => FactoryGirl.create(:finance_transaction_category, :is_income => true),
        :transaction_date => Date.current + 10.days) }

      it 'returns nil' do
        FinanceTransaction.incomes(start_date, end_date).should == []
      end
    end
  end

  describe '#student_payee' do
    context 'employee is found' do
      let(:employee) { FactoryGirl.create(:employee) }
      let!(:fin_tran) { FactoryGirl.create(:finance_transaction, :payee => employee) }

      it 'returns student_payee' do
        fin_tran.student_payee.should == employee
      end
    end

    context 'archived student is found and employee is not found' do
      let(:archived_student) { FactoryGirl.create(:archived_student, :former_id => '123') }
      let!(:fin_tran) { FactoryGirl.create(:finance_transaction, :payee_id => archived_student.former_id) }

      it 'returns student_payee' do
        fin_tran.student_payee.should == archived_student
      end
    end
  end

  describe '#create_auto_transaction' do
    let!(:ft_category) { FactoryGirl.create(:finance_transaction_category) }
    let!(:fin_tran) { FactoryGirl.build(:finance_transaction,
      :category => ft_category) }

    context 'trigger is found' do
      before { FactoryGirl.create(:finance_transaction_trigger, :finance_category => ft_category) }

      it 'create new transaction' do
        lambda { fin_tran.save }.should change { FinanceTransaction.count }.by(2)
      end
    end

    context 'trigger is not found' do
      before { FactoryGirl.create(:finance_transaction_trigger) }
      
      it 'do not create new transaction' do
        lambda { fin_tran.save }.should change { FinanceTransaction.count }.by(1)
      end
    end
  end

  describe '#update_auto_transaction' do
    let!(:ft_category) { FactoryGirl.create(:finance_transaction_category) }
    let!(:fin_tran) { FactoryGirl.create(:finance_transaction, :category => ft_category) }

    context 'master_transaction_id is equal to id' do
      before { FactoryGirl.create(:finance_transaction, :master_transaction_id => 210) }

      it 'delete transaction' do
        fin_tran.id = 210
        lambda { fin_tran.save }.should change { FinanceTransaction.count }.by(-1)
      end
    end

    context 'master_transaction_id equal 0' do
      before { FactoryGirl.create(:finance_transaction_trigger, :finance_category => ft_category) }

      it 'create new transaction' do
        lambda { fin_tran.save }.should change { FinanceTransaction.count }.by(1)
      end
    end
  end

  describe '#delete_auto_transaction' do
    let!(:fin_tran) { FactoryGirl.create(:finance_transaction, :id => 210) }

    context 'master_transaction_id is found' do
      before { FactoryGirl.create(:finance_transaction, :master_transaction_id => 210) }

      it 'delete transactions' do
        lambda { fin_tran.destroy }.should change { FinanceTransaction.count }.by(-2)
      end
    end

    context 'master_transaction_id is not found' do
      before { FactoryGirl.create(:finance_transaction, :master_transaction_id => 250) }

      it 'delete transaction' do
        lambda { fin_tran.destroy }.should change { FinanceTransaction.count }.by(-1)
      end
    end
  end

  describe '#add_voucher_or_receipt_number' do
    context 'is_income? and master_transaction_id eq zero' do
      let!(:ft_category) { FactoryGirl.create(:finance_transaction_category, :is_income => true) }
        
      context 'last_receipt_no is not nil' do
        let!(:fin_tran) { FactoryGirl.build(:finance_transaction,
          :category => ft_category,
          :receipt_no => 'CA1892734') }

        it 'add receipt_number' do
          fin_tran.save
          fin_tran.receipt_no.should == 'CA1892735'
        end
      end

      context 'last_receipt_no is nil' do
        let!(:fin_tran) { FactoryGirl.build(:finance_transaction,
          :category => ft_category,
          :receipt_no => nil) }

        it 'add receipt_number' do
          fin_tran.save
          fin_tran.receipt_no.should == '1'
        end
      end
    end

    context 'not is_income? or master_transaction_id not equal zero' do
      let!(:ft_category) { FactoryGirl.create(:finance_transaction_category) }
        
      context 'last_voucher_no is not nil' do
        let!(:fin_tran) { FactoryGirl.build(:finance_transaction,
          :category => ft_category,
          :voucher_no => 'VC189') }

        it 'add voucher_number' do
          fin_tran.save
          fin_tran.voucher_no.should == 'VC190'
        end
      end

      context 'last_voucher_no is nil' do
        let!(:fin_tran) { FactoryGirl.build(:finance_transaction,
          :category => ft_category,
          :voucher_no => nil) }

        it 'add voucher_number' do
          fin_tran.save
          fin_tran.voucher_no.should == '1'
        end
      end
    end
  end
end