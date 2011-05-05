class CreateLiabilities < ActiveRecord::Migration
  def self.up
    create_table :liabilities do |t|
      t.string :title
      t.text :description
      t.integer :amount
      t.boolean :is_solved,:default=>false
      t.boolean :is_deleted, :default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :liabilities
  end
end
