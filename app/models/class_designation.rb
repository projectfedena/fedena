class ClassDesignation < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :cgpa,:if=>:has_gpa
  validates_numericality_of :marks, :if=>:has_cwa

  belongs_to :course

  def has_gpa
    self.course.gpa_enabled?
  end

  def has_cwa
    self.course.cwa_enabled? or self.course.normal_enabled?
  end

  HUMANIZED_COLUMNS = {:cgpa => "CGPA"}

  def self.human_attribute_name(attribute)
    HUMANIZED_COLUMNS[attribute.to_sym] || super
  end
end
