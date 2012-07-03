class AddCourseIdToRankingLevels < ActiveRecord::Migration
  def self.up
    add_column :ranking_levels, :course_id, :integer
  end

  def self.down
    remove_column :ranking_levels, :course_id
  end
end
