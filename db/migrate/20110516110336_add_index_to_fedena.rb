class AddIndexToFedena < ActiveRecord::Migration
  def self.up
      add_index :users, [:username],:limit => 10
      add_index :finance_fee_collections, [:fee_category_id]
      add_index :finance_fees, [:fee_collection_id, :student_id]
      add_index :batch_students, [:batch_id, :student_id]
      add_index :subjects, [:batch_id, :elective_group_id,:is_deleted]
      add_index :configurations, [:config_key],:limit => 10
      add_index :exam_scores, [:student_id,:exam_id]
      add_index :archived_exam_scores, [:student_id,:exam_id]
      add_index :exams, [:exam_group_id,:subject_id]
      add_index :grouped_exams, [:batch_id]
      add_index :grading_levels, [:batch_id,:is_deleted]
      add_index :students_subjects, [:student_id,:subject_id]
      add_index :period_entries, [:month_date,:batch_id]
      add_index :timetable_entries, [:weekday_id,:batch_id,:class_timing_id],:name => 'by_timetable'
      add_index :employees_subjects, [:subject_id]
      add_index :weekdays, [:batch_id]
      add_index :events, [:is_common,:is_holiday,:is_exam]
      add_index :batch_events, [:batch_id]
      add_index :class_timings, [:batch_id,:start_time,:end_time]

  end

  def self.down
      remove_index :users, [:username]
      remove_index :finance_fee_collections, [:fee_category_id]
      remove_index :finance_fees, [:fee_collection_id, :student_id]
      remove_index :batch_students, [:batch_id, :student_id]
      remove_index :subjects, [:batch_id, :elective_group_id,:is_deleted]
      remove_index :configurations, [:config_key]
      remove_index :exam_scores, [:student_id,:exam_id]
      remove_index :exams, [:exam_group_id,:subject_id]
      remove_index :archived_exam_scores, [:student_id,:exam_id]
      remove_index :grouped_exams, [:batch_id]
      remove_index :grading_levels, [:batch_id,:is_deleted]
      remove_index :students_subjects, [:student_id,:subject_id]
      remove_index :period_entries, [:month_date,:batch_id]
      remove_index :timetable_entries,:name => 'by_timetable'
      remove_index :employees_subjects, [:subject_id]
      remove_index :weekdays, [:batch_id]
      remove_index :events, [:is_common,:is_holiday,:is_exam]
      remove_index :batch_events, [:batch_id]
      remove_index :class_timings, [:batch_id,:start_time,:end_time]
  end
end
