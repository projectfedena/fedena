class CreateFeeDiscounts < ActiveRecord::Migration
  def self.up
    create_table :fee_discounts do |t|
      t.string     :type
      t.string     :name
      t.references :receiver
      t.references :finance_fee_category
      t.decimal    :discount, :precision =>15, :scale => 2
      t.boolean    :is_amount, :default=> false
    end

  end

  def self.down
    drop_table :fee_discounts
  end
end
