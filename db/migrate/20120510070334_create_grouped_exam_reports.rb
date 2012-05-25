class CreateGroupedExamReports < ActiveRecord::Migration
  def self.up
    create_table :grouped_exam_reports do |t|
      t.integer :batch_id
      t.integer :student_id
      t.integer :exam_group_id
      t.decimal :marks, :precision=>15, :scale=>2
      t.string :score_type
      t.integer :subject_id

      t.timestamps
    end
  end

  def self.down
    drop_table :grouped_exam_reports
  end
end
