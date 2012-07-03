class RankingLevel < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :gpa,:if=>:has_gpa
  validates_numericality_of :marks, :if=>:has_cwa
  validates_numericality_of :subject_count, :allow_nil=>true

  belongs_to :course

  LIMIT_TYPES = %w(upper lower exact)

  def has_gpa
    self.course.grading_type=="1"
  end

  def has_cwa
    self.course.grading_type=="2" or self.course.grading_type=="0" or self.course.grading_type.nil?
  end
end
