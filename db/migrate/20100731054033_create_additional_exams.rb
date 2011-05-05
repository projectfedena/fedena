class CreateAdditionalExams < ActiveRecord::Migration
  def self.up
    create_table :additional_exams do |t|
      t.references :additional_exam_group
      t.references :subject
      t.datetime   :start_time
      t.datetime   :end_time
      t.integer    :maximum_marks
      t.integer    :minimum_marks
      t.references :grading_level
      t.integer    :weightage, :default => 0

      t.references :event
      t.timestamps
      t.timestamps
    end
  end

  def self.down
    drop_table :additional_exams
  end
end
