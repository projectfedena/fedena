class CreateFeeCollectionDiscounts < ActiveRecord::Migration
  def self.up
    create_table :fee_collection_discounts do |t|
      t.string     :type
      t.string     :name
      t.references :receiver
      t.references :finance_fee_collection
      t.decimal    :discount, :precision =>15, :scale => 2
      t.boolean    :is_amount, :default=> false
      t.timestamps
    end
  end

  def self.down
    drop_table :fee_collection_discounts
  end
end
