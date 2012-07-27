#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

class Course < ActiveRecord::Base

  GRADINGTYPES = {"1"=>"GPA","2"=>"CWA","3"=>"CCE"}
  
  validates_presence_of :course_name, :code
  validate :presence_of_initial_batch, :on => :create

  has_many :batches
  has_many :batch_groups
  has_many :ranking_levels
  has_many :class_designations
  accepts_nested_attributes_for :batches
  has_and_belongs_to_many :observation_groups
  has_and_belongs_to_many_with_deferred_save :cce_weightages
  
  before_save :cce_weightage_valid

  named_scope :active, :conditions => { :is_deleted => false }, :order => 'course_name asc'
  named_scope :deleted, :conditions => { :is_deleted => true }, :order => 'course_name asc'
  named_scope :cce, {:select => "courses.*",:conditions=>{:grading_type => GRADINGTYPES.invert["CCE"]}, :order => 'course_name asc'}

  def presence_of_initial_batch
    errors.add_to_base "#{t('should_have_an_initial_batch')}" if batches.length == 0
  end

  def inactivate
    update_attribute(:is_deleted, true)
  end
  
  def full_name
    "#{course_name} #{section_name}"
  end

  def active_batches
    self.batches.all(:conditions=>{:is_active=>true,:is_deleted=>false})
  end

  def has_batch_groups_with_active_batches
    batch_groups = self.batch_groups
    if batch_groups.empty?
      return false
    else
      batch_groups.each do|b|
        return true if b.has_active_batches==true
      end
    end
    return false
  end

  def find_course_rank(batch_ids,sort_order)
    batches = Batch.find_all_by_id(batch_ids)
    @students = Student.find_all_by_batch_id(batches)
    @grouped_exams = GroupedExam.find_all_by_batch_id(batches)
    ordered_scores = []
    student_scores = []
    ranked_students = []
    @students.each do|student|
      score = GroupedExamReport.find_by_student_id_and_batch_id_and_score_type(student.id,student.batch_id,"c")
      marks = 0
      unless score.nil?
        marks = score.marks
      end
      ordered_scores << marks
      student_scores << [student.id,marks]
    end
    ordered_scores = ordered_scores.compact.uniq.sort.reverse
    @students.each do |student|
      m = 0
      student_scores.each do|student_score|
        if student_score[0]==student.id
          m = student_score[1]
        end
      end
      if sort_order=="" or sort_order=="rank-ascend" or sort_order=="rank-descend"
        ranked_students << [(ordered_scores.index(m) + 1),m,student.id,student]
      else
        ranked_students << [student.full_name,(ordered_scores.index(m) + 1),m,student.id,student]
      end
    end
    if sort_order=="" or sort_order=="rank-ascend" or sort_order=="name-ascend"
      ranked_students = ranked_students.sort
    else
      ranked_students = ranked_students.sort.reverse
    end
  end

  def cce_enabled?
    Configuration.cce_enabled? and grading_type == "3"
  end

  def gpa_enabled?
    Configuration.has_gpa? and self.grading_type=="1"
  end

  def cwa_enabled?
    Configuration.has_cwa? and self.grading_type=="2"
  end

  def normal_enabled?
    self.grading_type.nil? or self.grading_type=="0"
  end
  #  def guardian_email_list
  #    email_addresses = []
  #    students = self.students
  #    students.each do |s|
  #      email_addresses << s.immediate_contact.email unless s.immediate_contact.nil?
  #    end
  #    email_addresses
  #  end
  #
  #  def student_email_list
  #    email_addresses = []
  #    students = self.students
  #    students.each do |s|
  #      email_addresses << s.email unless s.email.nil?
  #    end
  #    email_addresses
  #  end
  class << self
    def grading_types
      hsh =  ActiveSupport::OrderedHash.new
      hsh["0"]="Normal"
      types = Configuration.get_grading_types
      types.each{|t| hsh[t] = GRADINGTYPES[t]}
      hsh
    end
    def grading_types_as_options
      grading_types.invert.sort_by{|k,v| v}
    end
  end

  def cce_weightages_for_exam_category(cce_exam_cateogry_id)
    cce_weightages.all(:conditions=>{:cce_exam_category_id=>cce_exam_cateogry_id})
  end

  private

  def cce_weightage_valid
    cce_weightages.group_by(&:criteria_type).values.each do |v|
      unless v.collect(&:cce_exam_category_id).length == v.collect(&:cce_exam_category_id).uniq.length
        errors.add(:cce_weightages,"can't assign more than one FA or SA under a single exam category.")
        return false
      end
    end
    true

  end

end