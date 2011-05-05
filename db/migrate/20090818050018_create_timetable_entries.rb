class CreateTimetableEntries < ActiveRecord::Migration
  def self.up
    create_table :timetable_entries do |t|
      t.references :batch
      t.references :week_day
      t.references :class_timing
      t.references :subject
      t.references :employee
    end
  end

  def self.down
    drop_table :timetable_entries
  end
end
