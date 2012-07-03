class AddExamIdToAssessmentScores < ActiveRecord::Migration
  def self.up
    add_column  :assessment_scores,   :exam_id,   :integer
    add_column  :assessment_scores,   :batch_id,   :integer
  end

  def self.down
    remove_column  :assessment_scores,   :exam_id
    remove_column  :assessment_scores,   :batch_id
  end
end
