class AddTimetableIdToTimetableEntries < ActiveRecord::Migration
  def self.up
    add_column  :timetable_entries, :timetable_id, :integer
  end

  def self.down
    remove_column  :timetable_entries, :timetable_id
  end
end
