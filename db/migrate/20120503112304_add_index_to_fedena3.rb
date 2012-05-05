class AddIndexToFedena3 < ActiveRecord::Migration
  def self.up
    remove_index :timetable_entries,:name => 'by_timetable'
    remove_index :batches,[:is_deleted,:is_active]
    add_index :timetable_entries, [:timetable_id]
    add_index :timetables, [:start_date,:end_date],:name => 'by_start_and_end'
    add_index :students, [:batch_id]
    add_index :batches,[:is_deleted,:is_active,:course_id,:name]
    add_index :subject_leaves,[:month_date,:subject_id,:batch_id]
    add_index :subject_leaves,[:student_id,:batch_id]
    add_index :attendances,[:month_date,:batch_id]
    add_index :attendances,[:student_id,:batch_id]
  end

  def self.down
    add_index :timetable_entries, [:weekday_id,:batch_id,:class_timing_id],:name => 'by_timetable'
    add_index :batches,[:is_deleted,:is_active]
    remove_index :timetable_entries, [:timetable_id]
    remove_index :batches,[:is_deleted,:is_active,:course_id,:name]
    remove_index :students, [:batch_id]
    remove_index :timetables, :name => 'by_start_and_end'
    remove_index :subject_leaves,[:student_id,:batch_id]
    remove_index :subject_leaves,[:month_date,:subject_id,:batch_id]
    remove_index :attendances,[:month_date,:batch_id]
    remove_index :attendances,[:student_id,:batch_id]
  end
end