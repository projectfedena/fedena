class CceGradeSet < ActiveRecord::Base
  has_many     :observation_groups
  has_many     :cce_grades#,:dependent => :destroy

  validates_presence_of :name

  def grade_string_for(point)
    grade_obj = cce_grades.select{|g| g.grade_point.to_i == point.to_i}.first
    grade_obj.nil? ? "No Grade" : grade_obj.name
  end

  def max_grade_point
    cce_grades.collect(&:grade_point).max || 1
  end

end
