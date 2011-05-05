class CreateFinanceTransactions < ActiveRecord::Migration
  def self.up
    create_table :finance_transactions do |t|
      t.string     :title
      t.string     :description
      t.decimal    :amount, :precision =>15, :scale => 2
      t.boolean    :fine_included, :default => false
      t.references :category
      t.references :student
      t.references :finance_fees
    
      t.timestamps
    end
  end

  def self.down
    drop_table :finance_transactions
  end
end
