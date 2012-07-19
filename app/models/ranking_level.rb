class RankingLevel < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :gpa,:if=>:has_gpa
  validates_numericality_of :marks, :if=>:has_cwa
  validates_numericality_of :subject_count, :allow_nil=>true

  belongs_to :course

  LIMIT_TYPES = %w(upper lower exact)

  def has_gpa
    self.course.gpa_enabled?
  end

  def has_cwa
    self.course.cwa_enabled? or self.course.normal_enabled?
  end
end
