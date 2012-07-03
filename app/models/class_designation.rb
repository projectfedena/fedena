class ClassDesignation < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :cgpa,:if=>:has_gpa
  validates_numericality_of :marks, :if=>:has_cwa

  belongs_to :course

 def has_gpa
    self.course.grading_type=="1"
  end

  def has_cwa
    self.course.grading_type=="2" or self.course.grading_type=="0" or self.course.grading_type.nil?
  end
end
