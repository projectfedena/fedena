class CreateAdditionalExamScores < ActiveRecord::Migration
  def self.up
    create_table :additional_exam_scores do |t|
      t.references :student
      t.references :additional_exam
      t.decimal    :marks, :precision => 7, :scale => 2
      t.references :grading_level
      t.string     :remarks
      t.boolean    :is_failed
      t.timestamps
    end
  end

  def self.down
    drop_table :additional_exam_scores
  end
end
