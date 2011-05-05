class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string :title
      t.text :description
      t.integer :amount
      t.boolean :is_inactive,:default=>false
      t.boolean :is_deleted,:default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
