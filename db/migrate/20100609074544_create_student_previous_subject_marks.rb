class CreateStudentPreviousSubjectMarks < ActiveRecord::Migration
  def self.up
    create_table :student_previous_subject_marks do |t|
      t.references :student
      t.string    :subject
      t.string    :mark
    end
  end

  def self.down
    drop_table :student_previous_subject_marks
  end
end
