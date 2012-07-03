class CceGrade < ActiveRecord::Base
#  has_many      :assessment_scores
  belongs_to    :cce_grade_set
  validates_presence_of :name
  validates_presence_of :grade_point
  validates_numericality_of :grade_point
end
