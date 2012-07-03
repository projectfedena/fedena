class FaGroup < ActiveRecord::Base
  has_many :fa_criterias
  has_and_belongs_to_many :subjects
  belongs_to :cce_exam_category
  belongs_to :cce_grade_set
  has_many :cce_reports, :through=>:fa_criterias 
  
  validates_presence_of :name,  :desc,  :cce_exam_category_id,  :cce_grade_set_id,  :max_marks
  
end
