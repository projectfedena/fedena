class CreateClassTimings < ActiveRecord::Migration
  def self.up
    create_table :class_timings do |t|
      t.references :batch
      t.string     :name
      t.time       :start_time
      t.time       :end_time
      t.boolean    :is_break
    end
    create_defaults
  end

  def self.down
    drop_table :class_timings
  end

  def self.create_defaults
    ClassTiming.create(:name => "1",        :is_break => false)
    ClassTiming.create(:name => "2",        :is_break => false)
    ClassTiming.create(:name => "Interval", :is_break => true)
    ClassTiming.create(:name => "3",        :is_break => false)
    ClassTiming.create(:name => "4",        :is_break => false)
    ClassTiming.create(:name => "Lunch",    :is_break => true)
    ClassTiming.create(:name => "5",        :is_break => false)
    ClassTiming.create(:name => "6",        :is_break => false)
    ClassTiming.create(:name => "7",        :is_break => false)
  end
end
