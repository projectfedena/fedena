class ClassDesignation < ActiveRecord::Base
  validates_presence_of :name
  validates_numericality_of :cgpa,:if=>:has_gpa
  validates_numericality_of :marks, :if=>:has_cwa

  def has_gpa
    Configuration.find_by_config_key("GPA").config_value=="1"
  end

  def has_cwa
    Configuration.find_by_config_key("CWA").config_value=="1"
  end
end
