class CreateGroupedBatches < ActiveRecord::Migration
  def self.up
    create_table :grouped_batches do |t|
      t.integer :batch_group_id
      t.integer :batch_id

      t.timestamps
    end
  end

  def self.down
    drop_table :grouped_batches
  end
end
