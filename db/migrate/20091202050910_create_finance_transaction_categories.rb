class CreateFinanceTransactionCategories < ActiveRecord::Migration
  def self.up
    create_table :finance_transaction_categories do |t|
      t.string  :name
      t.string  :description
      t.boolean :is_income
      t.boolean :deleted, :null => false, :default => false
    end
  end

  def self.down
    drop_table :finance_transaction_categories
  end
end
