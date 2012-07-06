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

class Batch < ActiveRecord::Base
  GRADINGTYPES = {"1"=>"GPA","2"=>"CWA","3"=>"CCE"}

  belongs_to :course

  has_many :students
  has_many :grouped_exam_reports
  has_many :grouped_batches
  has_many :archived_students
  has_many :grading_levels, :conditions => { :is_deleted => false }
  has_many :subjects, :conditions => { :is_deleted => false }
  has_many :employees_subjects, :through =>:subjects
  has_many :exam_groups
  has_many :fee_category , :class_name => "FinanceFeeCategory"
  has_many :elective_groups
  has_many :additional_exam_groups
  has_many :finance_fee_collections
  has_many :finance_transactions, :through => :students
  has_many :batch_events
  has_many :events , :through =>:batch_events
  has_many :batch_fee_discounts , :foreign_key => 'receiver_id'
  has_many :student_category_fee_discounts , :foreign_key => 'receiver_id'
  has_many :attendances
  has_many :subject_leaves
  has_many :timetable_entries
  has_many :cce_reports
  has_many :assessment_scores


  has_and_belongs_to_many :graduated_students, :class_name => 'Student', :join_table => 'batch_students'

  delegate :course_name,:section_name, :code, :to => :course
  delegate :grading_type, :cce_enabled?, :observation_groups, :cce_weightages, :to=>:course

  validates_presence_of :name, :start_date, :end_date

  named_scope :active,{ :conditions => { :is_deleted => false, :is_active => true },:joins=>:course,:select=>"`batches`.*,CONCAT(courses.code,'-',batches.name) as course_full_name",:order=>"course_full_name"}
  named_scope :inactive,{ :conditions => { :is_deleted => false, :is_active => false },:joins=>:course,:select=>"`batches`.*,CONCAT(courses.code,'-',batches.name) as course_full_name",:order=>"course_full_name"}
  named_scope :deleted,{:conditions => { :is_deleted => true },:joins=>:course,:select=>"`batches`.*,CONCAT(courses.code,'-',batches.name) as course_full_name",:order=>"course_full_name"}
  named_scope :cce, {:select => "batches.*",:joins => :course,:conditions=>["courses.grading_type = #{GRADINGTYPES.invert["CCE"]}"]}

  def validate
    errors.add(:start_date, "#{t('should_be_before_end_date')}.") \
      if self.start_date > self.end_date \
      if self.start_date and self.end_date
  end

  def full_name
    "#{code} - #{name}"
  end

  def course_section_name
    "#{course_name} - #{section_name}"
  end
  
  def inactivate
    update_attribute(:is_deleted, true)
    self.employees_subjects.destroy_all
  end

  def grading_level_list
    levels = self.grading_levels
    levels.empty? ? GradingLevel.default : levels
  end

  def fee_collection_dates
    FinanceFeeCollection.find_all_by_batch_id(self.id,:conditions => "is_deleted = false")
  end

  def all_students
    Student.find_all_by_batch_id(self.id)
  end

  def normal_batch_subject
    Subject.find_all_by_batch_id(self.id,:conditions=>["elective_group_id IS NULL AND is_deleted = false"])
  end
  def elective_batch_subject(elect_group)
    Subject.find_all_by_batch_id_and_elective_group_id(self.id,elect_group,:conditions=>["elective_group_id IS NOT NULL AND is_deleted = false"])
  end
  def has_own_weekday
    Weekday.find_all_by_batch_id(self.id,:conditions=>{:is_deleted=>false}).present?
  end

  def allow_exam_acess(user)
    flag = true
    if user.employee? and user.role_symbols.include?(:subject_exam)
      flag = false if user.employee_record.subjects.all(:conditions=>"batch_id = '#{self.id}'").blank?
    end
    return flag
  end

  def is_a_holiday_for_batch?(day)
    return true if Event.holidays.count(:all, :conditions => ["start_date <=? AND end_date >= ?", day, day] ) > 0
    false
  end

  def holiday_event_dates
    @common_holidays ||= Event.holidays.is_common
    @batch_holidays=events.holidays
    all_holiday_events = @batch_holidays+@common_holidays
    event_holidays = []
    all_holiday_events.each do |event|
      event_holidays+=event.dates
    end
    return event_holidays #array of holiday event dates
  end
  
  def return_holidays(start_date,end_date)
    @common_holidays ||= Event.holidays.is_common
    @batch_holidays=self.events(:all,:conditions=>{:is_holiday=>true})
    all_holiday_events = @batch_holidays+@common_holidays
    all_holiday_events.reject!{|h| !(h.start_date>=start_date and h.end_date<=end_date)}
    event_holidays = []
    all_holiday_events.each do |event|
      event_holidays+=event.dates
    end
    return event_holidays #array of holiday event dates
  end

  def find_working_days(start_date,end_date)
    start=[]
    start<<self.start_date.to_date
    start<<start_date.to_date
    stop=[]
    stop<<self.end_date.to_date
    stop<<end_date.to_date
    all_days=start.max..stop.min
    weekdays=Weekday.weekday_by_day(self.id).keys
    holidays=return_holidays(start_date,end_date)
    non_holidays=all_days.to_a-holidays
    range=non_holidays.select{|d| weekdays.include? d.wday}
    return range
  end


  def working_days(date)
    start=[]
    start<<self.start_date.to_date
    start<<date.beginning_of_month.to_date
    stop=[]
    stop<<self.end_date.to_date
    stop<<date.end_of_month.to_date
    all_days=start.max..stop.min
    weekdays=Weekday.weekday_by_day(self.id).keys
    holidays=holiday_event_dates
    non_holidays=all_days.to_a-holidays
    range=non_holidays.select{|d| weekdays.include? d.wday}
  end

  def academic_days
    all_days=start_date.to_date..Date.today
    weekdays=Weekday.weekday_by_day(self.id).keys
    holidays=holiday_event_dates
    non_holidays=all_days.to_a-holidays
    range=non_holidays.select{|d| weekdays.include? d.wday}
  end

  def total_subject_hours(subject_id)
    days=academic_days
    count=0
    unless subject_id == 0
      subject=Subject.find subject_id
      days.each do |d|
        count=count+ Timetable.subject_tte(subject_id, d).count
      end
    else
      days.each do |d|
        count=count+ Timetable.tte_for_the_day(self,d).count
      end
    end
    count
  end

  

  def subject_hours(starting_date,ending_date,subject_id)
    unless subject_id == 0
      subject=Subject.find(subject_id)
      unless subject.elective_group.nil?
        subject=subject.elective_group.subjects.first
      end
      #          Timetable.all(:conditions=>["('#{starting_date}' BETWEEN start_date AND end_date) OR ('#{ending_date}' BETWEEN start_date AND end_date) OR (start_date BETWEEN '#{starting_date}' AND #{ending_date}) OR (end_date BETWEEN '#{starting_date}' AND '#{ending_date}')"])
      entries = TimetableEntry.find(:all,:joins=>:timetable,:include=>:weekday,:conditions=>["((? BETWEEN start_date AND end_date) OR (? BETWEEN start_date AND end_date) OR (start_date BETWEEN ? AND ?) OR (end_date BETWEEN ? AND ?)) AND timetable_entries.subject_id = ? AND timetable_entries.batch_id = ?",starting_date,ending_date,starting_date,ending_date,starting_date,ending_date,subject.id,id]).group_by(&:timetable_id)
    else
      entries = TimetableEntry.find(:all,:joins=>:timetable,:include=>:weekday,:conditions=>["((? BETWEEN start_date AND end_date) OR (? BETWEEN start_date AND end_date) OR (start_date BETWEEN ? AND ?) OR (end_date BETWEEN ? AND ?)) AND timetable_entries.batch_id = ?",starting_date,ending_date,starting_date,ending_date,starting_date,ending_date,id]).group_by(&:timetable_id)
    end
    timetable_ids=entries.keys
    hsh2=Hash.new
    holidays=holiday_event_dates
    unless timetable_ids.nil?
      timetables=Timetable.find(timetable_ids)
      hsh = Hash.new
      entries.each do |k,val|
        hsh[k]=val.group_by(&:day_of_week)
      end
      timetables.each do |tt|
        ([starting_date,start_date.to_date,tt.start_date].max..[tt.end_date,end_date.to_date,ending_date,Date.today].min).each do |d|
          hsh2[d]=hsh[tt.id][d.wday] 
        end
      end
    end
    holidays.each do |h|
      hsh2.delete(h)
    end
    hsh2
  end

  def create_coscholastic_reports
    report_hash={}
    observation_groups.scoped(:include=>[{:observations=>:assessment_scores},{:cce_grade_set=>:cce_grades}]).each do |og|
      og.observations.each do |o|
        report_hash[o.id]={}
        o.assessment_scores.scoped(:conditions=>{:exam_id=>nil,:batch_id=>id}).group_by(&:student_id).each{|k,v| report_hash[o.id][k]=(v.sum(&:grade_points)/v.count.to_f).round}
        report_hash[o.id].each do |key,val|
          o.cce_reports.build(:student_id=>key, :grade_string=>og.cce_grade_set.grade_string_for(val), :batch_id=> id)
        end
        o.save
      end
    end
  end

  def delete_coscholastic_reports
    CceReport.delete_all({:batch_id=>id,:exam_id=>nil})
  end

  def fa_groups
    FaGroup.all(:joins=>:subjects, :conditions=>{:subjects=>{:batch_id=>id}}).uniq
  end
  
  def create_scholastic_reports
    report_hash={}
    fa_groups.each do |fg|
      fg.fa_criterias.all(:include=>:assessment_scores).each do |f|
        report_hash[f.id]={}
        f.assessment_scores.scoped(:conditions=>["exam_id IS NOT NULL AND batch_id = ?",id]).group_by(&:exam_id).each do |k1,v1|
          report_hash[f.id][k1]={}
          v1.group_by(&:student_id).each{|k2,v2| report_hash[f.id][k1][k2]=(v2.sum(&:grade_points)/v2.count.to_f).round}
        end
        report_hash[f.id].each do |k1,v1|
          v1.each do |k2,v2|
            f.cce_reports.build(:student_id=>k2, :grade_string=>v2,:exam_id=>k1, :batch_id=> id)
          end
        end
        f.save
      end
    end
  end

  def delete_scholastic_reports
    CceReport.delete_all(["batch_id = ? AND exam_id > 0", id])
  end

  def generate_cce_reports
    CceReport.transaction do
      delete_scholastic_reports
      create_scholastic_reports
      delete_coscholastic_reports
      create_coscholastic_reports
    end
  end

  def employees
    unless employee_id.nil?
      employee_ids = employee_id.split(",")
      Employee.find(employee_ids)
    else
      []
    end
  end

  def perform
    #this is for cce_report_generation use flags if need job for other works
    generate_cce_reports    
  end

  def delete_student_cce_report_cache
    students.all(:select=>"id, batch_id").each do |s|
      s.delete_individual_cce_report_cache
    end
  end

  def check_credit_points
    grading_level_list.collect{|g| g.credit_points}.include? ""
  end
  
end
