class AddRecieptAndVoucherNoToFinanceTransaction < ActiveRecord::Migration
  def self.up
    add_column :finance_transactions, :receipt_no,  :string
    add_column :finance_transactions, :voucher_no,  :string
  end

  def self.down
    remove_column :finance_transactions, :receipt_no
    remove_column :finance_transactions, :voucher_no
  end
end
