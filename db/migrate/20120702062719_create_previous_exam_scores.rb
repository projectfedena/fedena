class CreatePreviousExamScores < ActiveRecord::Migration
  def self.up
    create_table :previous_exam_scores do |t|
      t.references :student
      t.references :exam
      t.decimal :marks, :precision => 7, :scale => 2
      t.integer :grading_level_id
      t.string :remarks
      t.boolean :is_failed

      t.timestamps
    end
  end

  def self.down
    drop_table :previous_exam_scores
  end
end
