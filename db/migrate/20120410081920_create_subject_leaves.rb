class CreateSubjectLeaves < ActiveRecord::Migration
  def self.up
    create_table :subject_leaves do |t|
      t.integer     :student_id
      t.date        :month_date
      t.integer     :subject_id
      t.integer     :employee_id
      t.integer     :class_timing_id
      t.string      :reason
      t.timestamps
    end
  end

  def self.down
    drop_table :subject_leaves
  end
end
