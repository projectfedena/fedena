class AdditionalExamGroup < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :students_list
  belongs_to :batch
  has_many :additional_exams, :dependent => :destroy
  before_destroy :removable?

  accepts_nested_attributes_for :additional_exams

  attr_accessor :maximum_marks, :minimum_marks, :weightage

  def before_save
    self.exam_date = self.exam_date || Date.today
  end

  def removable?
   self.additional_exams.reject{|e| e.removable?}.empty?
  end


  def students
     students_array=[]
     list=self.students_list.split(",")
      list.each do |id|
        student =  Student.find_by_id(id)
        students_array.push student unless student.nil?
      end
      return students_array
  end
  
end
