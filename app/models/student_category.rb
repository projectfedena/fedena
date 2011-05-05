class StudentCategory < ActiveRecord::Base

  has_many :students
  has_many :fee_category ,:class_name =>"FinanceFeeCategory"
  before_destroy :check_dependence
  validates_presence_of :name
  validates_uniqueness_of :name, :scope=>:is_deleted,:case_sensitive => false, :if=> 'is_deleted == false'

  named_scope :active, :conditions => { :is_deleted => false}

  def empty_students
    Student.find_all_by_student_category_id(self.id).each do |s|
      s.update_attributes(:student_category_id=>nil)
    end

  end

  def check_dependence
    if Student.find_all_by_student_category_id(self.id).blank?
       errors.add_to_base( "Category is in use. Can not delete")
       return false
    end

  end
end
