class RemoveTableAssessmentTools < ActiveRecord::Migration
  def self.up
    drop_table :assessment_tools
  end

  def self.down
    create_table :assessment_tools do |t|
      t.string        :name
      t.string        :desc
      t.integer       :descriptive_indicator_id
      t.timestamps
    end
  end

end
