class AddDescriptiveIndicatorIdToAssessmentScores < ActiveRecord::Migration
  def self.up
    add_column    :assessment_scores,   :descriptive_indicator_id,  :integer
    remove_column :assessment_scores,   :assessment_tool_id
  end

  def self.down
    add_column    :assessment_scores,   :assessment_tool_id,  :integer
    remove_column :assessment_scores,   :descriptive_indicator_id
  end
end
