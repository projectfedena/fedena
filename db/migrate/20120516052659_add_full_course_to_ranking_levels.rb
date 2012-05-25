class AddFullCourseToRankingLevels < ActiveRecord::Migration
  def self.up
    add_column :ranking_levels, :full_course, :boolean, :default=>false
  end

  def self.down
    remove_column :ranking_levels, :full_course
  end
end
