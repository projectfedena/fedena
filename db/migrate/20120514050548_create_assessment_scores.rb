class CreateAssessmentScores < ActiveRecord::Migration
  def self.up
    create_table :assessment_scores do |t|
      t.integer       :student_id
      t.integer       :assessment_tool_id
#      t.integer       :exam_id
      t.integer       :grade_points
      t.timestamps
    end
  end

  def self.down
    drop_table :assessment_scores
  end
end
