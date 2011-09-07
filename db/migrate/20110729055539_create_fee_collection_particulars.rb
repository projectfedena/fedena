class CreateFeeCollectionParticulars < ActiveRecord::Migration
  def self.up
    create_table :fee_collection_particulars do |t|
      
      t.string      :name
      t.text        :description
      t.decimal     :amount, :precision => 12, :scale => 2
      t.references  :finance_fee_collection
      t.references  :student_category
      t.string      :admission_no
      t.references  :student
      t.boolean     :is_deleted, :null => false, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :fee_collection_particulars
  end
end
