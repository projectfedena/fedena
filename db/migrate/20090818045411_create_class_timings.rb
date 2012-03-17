class CreateClassTimings < ActiveRecord::Migration
  def self.up
    create_table :class_timings do |t|
      t.references :batch
      t.string     :name
      t.time       :start_time
      t.time       :end_time
      t.boolean    :is_break
    end
    end

  def self.down
    drop_table :class_timings
  end
  
end
