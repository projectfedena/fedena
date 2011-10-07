class AddPolymorphicToFinanceTransaction < ActiveRecord::Migration
  def self.up
    add_column :finance_transactions, :finance_id,  :integer
    add_column :finance_transactions, :finance_type,:string
    add_column :finance_transactions, :payee_id,  :integer
    add_column :finance_transactions, :payee_type,:string
  end

  def self.down
    remove_column :finance_transactions, :finance_id
    remove_column :finance_transactions, :finance_type
    remove_column :finance_transactions, :payee_id
    remove_column :finance_transactions, :payee_type
  end
end
