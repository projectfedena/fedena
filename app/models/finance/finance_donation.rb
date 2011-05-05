class FinanceDonation < ActiveRecord::Base
  belongs_to :transaction, :class_name => 'FinanceTransaction',  :dependent => :destroy
  validates_presence_of :donor, :amount
  validates_numericality_of :amount, :greater_than => 0

  before_create :create_finance_transaction

  def create_finance_transaction
    transaction = FinanceTransaction.create(
      :title => "Donation from " + donor,
      :description => description,
      :amount => amount,
      :transaction_date => transaction_date,
      :category => FinanceTransactionCategory.find_by_name('Donation')
    )
    self.transaction_id = transaction.id
  end
end
