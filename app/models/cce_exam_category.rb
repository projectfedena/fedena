class CceExamCategory < ActiveRecord::Base
  has_many                :cce_weightages
  has_many :cce_exam_categories_exam_groups
  has_many :exam_groups,  :through => :cce_exam_categories_exam_groups
  has_many                :fa_groups
  validates_presence_of     :name
  validates_presence_of     :desc
end
