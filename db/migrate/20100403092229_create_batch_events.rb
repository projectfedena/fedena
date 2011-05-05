class CreateBatchEvents < ActiveRecord::Migration
  def self.up
    create_table :batch_events do |t|
      t.references :event
      t.references :batch
      t.timestamps
    end
  end

  def self.down
    drop_table :batch_events
  end
end
