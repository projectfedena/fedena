class CreateFinanceTransactionTriggers < ActiveRecord::Migration
  def self.up
    create_table :finance_transaction_triggers do |t|
      t.references :finance_category
      t.decimal    :percentage, :precision => 8, :scale => 2
      t.string     :title
      t.string     :description
    end
  end

  def self.down
    drop_table :finance_transaction_triggers
  end
end
