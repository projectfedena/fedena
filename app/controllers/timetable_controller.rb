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

class TimetableController < ApplicationController
  before_filter :login_required
  before_filter :protect_other_student_data
  filter_access_to :all
  
  def generate
    @batches = Batch.active
    if request.post?
      @batch = Batch.find params[:timetable][:batch_id]
      @config = Configuration.find_by_config_key('StudentAttendanceType')
      @start_date = @batch.start_date.to_date
      @end_date = @batch.end_date.to_date
      not_set_for_batch = Weekday.for_batch(@batch.id).empty?
      set = 0
      (@start_date..@end_date).each do |d|
        weekday = not_set_for_batch ? (Weekday.find_by_batch_id_and_weekday(nil,d.wday)) :  (Weekday.find_by_batch_id_and_weekday(@batch.id,d.wday))
        unless weekday.nil?
          @period = PeriodEntry.find_all_by_month_date_and_batch_id(d,@batch.id)
          if @period.empty?
            unless Event.is_a_holiday?(d)
              unless @config.config_value == 'Daily'
                entries = TimetableEntry.find_all_by_weekday_id_and_batch_id(weekday.id, @batch.id)
                entries.each do |tte|
                  if tte.subject.nil?
                    PeriodEntry.create(:month_date=> d, :batch_id => @batch.id,:class_timing_id => tte.class_timing_id, :employee_id => tte.employee_id)
                  elsif tte.subject.elective_group_id.nil?
                    PeriodEntry.create(:month_date=> d, :batch_id => @batch.id, :subject_id => tte.subject_id, :class_timing_id => tte.class_timing_id, :employee_id => tte.employee_id)
                  else
                    sub = Subject.find_all_by_elective_group_id_and_batch_id(tte.subject.elective_group_id, @batch.id)
                    sub.each do |s|
                      PeriodEntry.create(:month_date=> d, :batch_id => @batch.id, :subject_id => s.id, :class_timing_id => tte.class_timing_id, :employee_id => tte.employee_id)
                  end
                end
              end
              set = 2
            else
              PeriodEntry.create(:month_date=> d, :batch_id => @batch.id)
              set = 2
            end
          end
        else
          if @config.config_value == "SubjectWise"
            if d >= Date.today
              entries = TimetableEntry.find_all_by_weekday_id_and_batch_id(weekday.id, @batch.id)
              entries.each do |tte|
                @period.each do |p|
                  if tte.class_timing_id == p.class_timing_id
                    unless tte.subject_id == p.subject_id
                      PeriodEntry.update(p.id, :month_date=> d, :batch_id => @batch.id, :subject_id => tte.subject_id, :class_timing_id =>tte.class_timing_id, :employee_id => tte.employee_id)
                      set = 1
                    end
                  end
                end

              end
            end
          end
        end
      end
          
      if set == 0
        flash[:notice] = "#{t('flash1')}"
      elsif set == 1
        flash[:notice] = "#{t('flash2')}"
      else
        flash[:notice] = "#{t('flash3')}"
      end
    end
    
    @config = Configuration.available_modules
    if @config.include?('HR')
      redirect_to :action=>"edit2", :id => @batch.id
    else
      redirect_to :action=>"edit", :id => @batch.id
    end
  end
end

def extra_class
  @config = Configuration.available_modules
  unless   params[:extra_class].nil?
    @date = params[:extra_class][:date].to_date
    @batch = Batch.find(params[:extra_class][:batch_id])
    @period_entry = PeriodEntry.find_all_by_month_date_and_batch_id(@date,@batch.id)
    render (:update) do |page|
      if @period_entry.blank?
        flash[:notice] = "#{t('flash_msg16')}"
        page.replace_html 'extra-class-form', :partial=>"no_period_entry"
      else
        page.replace_html 'extra-class-form', :partial => "extra_class_form"
      end
    end
  end
      
end
def extra_class_edit
  @config = Configuration.available_modules
  @period_id = params[:id]
  @period_entry = PeriodEntry.find(@period_id)
  @subjects = Subject.find_all_by_batch_id(@period_entry.batch_id,:conditions=>'is_deleted=false')
  @employee = EmployeesSubject.find_all_by_subject_id(@period_entry.subject_id)
end
def list_employee_by_subject
  @period_id = params[:period_id]
  @subject = Subject.find(params[:subject_id])
  @employee = EmployeesSubject.find_all_by_subject_id(@subject.id)
  render (:update) do |page|
    page.replace_html "employee-update-#{@period_id}", :partial => "list_employee_by_subject"
  end
end
def save_extra_class
  @period = PeriodEntry.find(params[:period_entry][:period_id])
  PeriodEntry.update(@period.id, :subject_id => params[:period_entry][:subject_id], :employee_id => params[:period_entry][:employee_id])
  @period = PeriodEntry.find(params[:period_entry][:period_id])
  render (:update) do |page|
    page.replace_html "tr-extra-class-#{@period.id}", :partial => 'extra_class_update'
  end
end

def timetable
  @config = Configuration.available_modules
  @batches = Batch.active
  unless params[:next].nil?
    @today = params[:next].to_date
    render (:update) do |page|
      page.replace_html "timetable", :partial => 'table'
    end
  else
    @today = Date.today
  end
end

def delete_subject
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  @errors = {"messages" => []}
  tte = TimetableEntry.update(params[:id], :subject_id => nil)
  @timetable = TimetableEntry.find_all_by_batch_id(tte.batch_id)
  render :partial => "edit_tt_multiple", :with => @timetable
end

def edit
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  @errors = {"messages" => []}
  @batch = Batch.find(params[:id])
  @timetable = TimetableEntry.find_all_by_batch_id(params[:id])
  @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
  if @class_timing.empty?
    @class_timing = ClassTiming.default
  end
  @day = Weekday.find_all_by_batch_id(@batch.id)
  if @day.empty?
    @day = Weekday.default
  end
  @subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>["elective_group_id IS NULL AND is_deleted = false"])
end

def select_class
  @batches = Batch.active
  if request.post?
    unless params[:timetable_entry][:batch_id].empty?
      @batch = Batch.find(params[:timetable_entry][:batch_id])
      @class_timings = ClassTiming.find_all_by_batch_id(@batch.id)
      if @class_timings.empty?
        @class_timings = ClassTiming.default
      end
      @days = Weekday.find_all_by_batch_id(@batch.id)
      if @days.empty?
        @days = Weekday.default
      end
      @days.each do |d|
        @class_timings.each do |p|
          TimetableEntry.create(:batch_id=>@batch.id, :weekday_id => d.id, :class_timing_id => p.id) \
            if TimetableEntry.find_by_batch_id_and_weekday_id_and_class_timing_id(@batch.id, d.id, p.id).nil?
        end
      end

      redirect_to :action => "edit", :id => @batch.id
    else
      flash[:notice]="#{t('select_a_batch_to_continue')}"
      redirect_to :action => "select_class"
    end
  end
end

def weekdays
  @batches = Batch.active
end

def tt_entry_update
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  @errors = {"messages" => []}
  subject = Subject.find(params[:sub_id])
  TimetableEntry.update(params[:tte_id], :subject_id => params[:sub_id])
  @timetable = TimetableEntry.find_all_by_batch_id(subject.batch_id)
  render :partial => "edit_tt_multiple", :with => @timetable
end

def tt_entry_noupdate
  render :update => "error_div_#{params[:tte_id]}", :text => "#{t('cancelled')}"
end

def update_multiple_timetable_entries
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  subject = Subject.find(params[:subject_id])
  tte_ids = params[:tte_ids].split(",").each {|x| x.to_i}
  course = subject.batch
  @validation_problems = {}

  tte_ids.each do |tte_id|
    errors = { "info" => {"sub_id" => subject.id, "tte_id" => tte_id},
      "messages" => [] }

    # check for weekly subject limit.
    errors["messages"] << "#{t('weekly_limit_reached')}" \
      if subject.max_weekly_classes <= TimetableEntry.count(:conditions => "subject_id = #{subject.id}")

    if errors["messages"].empty?
      TimetableEntry.update(tte_id, :subject_id => subject.id)
    else
      @validation_problems[tte_id] = errors
    end
  end

  @timetable = TimetableEntry.find_all_by_batch_id(course.id)
  render :partial => "edit_tt_multiple", :with => @timetable
end

def view
  @courses = Batch.active
end

def student_view
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  student = Student.find(params[:id])
  @batch = student.batch
  @timetable = TimetableEntry.find_all_by_batch_id(@batch.id)
  @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
  if @class_timing.empty?
    @class_timing = ClassTiming.default
  end
  @day = Weekday.find_all_by_batch_id(@batch.id)
  if @day.empty?
    @day = Weekday.default
  end
  @subjects = Subject.find_all_by_batch_id(@batch.id)
end

def update_timetable_view
  if params[:course_id] == ""
    render :update do |page|
      page.replace_html "timetable_view", :text => ""
    end
    return
  end
  @batch = Batch.find(params[:course_id])
  @timetable = TimetableEntry.find_all_by_batch_id(@batch.id)
  @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
  if @class_timing.empty?
    @class_timing = ClassTiming.default
  end
  @day = Weekday.find_all_by_batch_id(@batch.id)
  if @day.empty?
    @day = Weekday.default
  end

  @subjects = Subject.find_all_by_batch_id(@batch.id)
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  render :update do |page|
    page.replace_html "timetable_view", :partial => "view_timetable"
  end
end

#methods given below are for timetable with HR module connected

def select_class2
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  @batches = Batch.active
  if request.post?
    unless params[:timetable_entry][:batch_id].empty?
      @batch = Batch.find(params[:timetable_entry][:batch_id])
      @class_timings = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
      if @class_timings.empty?
        @class_timings = ClassTiming.default
      end
      @day = Weekday.find_all_by_batch_id(@batch.id)
      if @day.empty?
        @day = Weekday.default
      end
      @day.each do |d|
        @class_timings.each do |p|
          TimetableEntry.create(:batch_id=>@batch.id, :weekday_id => d.id, :class_timing_id => p.id) \
            if TimetableEntry.find_by_batch_id_and_weekday_id_and_class_timing_id(@batch.id, d.id, p.id).nil?
        end
      end
      redirect_to :action => "edit2", :id => @batch.id
    else
      flash[:notice]="#{t('select_a_batch_to_continue')}"
      redirect_to :action => "select_class2"
    end
  end
end

def edit2
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  @errors = {"messages" => []}
  @batch = Batch.find(params[:id])
  @timetable = TimetableEntry.find_all_by_batch_id(params[:id])
  @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions =>[ "is_break = false"], :order =>'start_time ASC')
  if @class_timing.empty?
    @class_timing = ClassTiming.default
  end
  @day = Weekday.find_all_by_batch_id(@batch.id)
  if @day.empty?
    @day = Weekday.default
  end
  @subjects = Subject.find_all_by_batch_id(@batch.id)
end

def update_employees
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  if params[:subject_id] == ""
    render :text => ""
    return
  end
  @employees_subject = EmployeesSubject.find_all_by_subject_id(params[:subject_id])
  render :partial=>"employee_list"
end

def update_multiple_timetable_entries2
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  employees_subject = EmployeesSubject.find(params[:emp_sub_id])
  tte_ids = params[:tte_ids].split(",").each {|x| x.to_i}
  @batch = employees_subject.subject.batch
  subject = employees_subject.subject
  employee = employees_subject.employee
  @validation_problems = {}

  tte_ids.each do |tte_id|
    tte = TimetableEntry.find(tte_id)
    errors = { "info" => {"sub_id" => employees_subject.subject_id, "emp_id"=> employees_subject.employee_id,"tte_id" => tte_id},
      "messages" => [] }

    # check for weekly subject limit.
    errors["messages"] << "#{t('weekly_limit_reached')}" \
      if subject.max_weekly_classes <= TimetableEntry.count(:conditions => "subject_id = #{subject.id}") unless subject.max_weekly_classes.nil?

    #check for overlapping classes
    overlap = TimetableEntry.find(:first,
      :conditions => "weekday_id = #{tte.weekday_id} AND class_timing_id = #{tte.class_timing_id} AND timetable_entries.employee_id = #{employee.id}", \
                     :joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0")
    unless overlap.nil?
      errors["messages"] << "#{t('class_overlap')}: #{overlap.batch.full_name}."
    end

    # check for max_hour_day exceeded
    employee = subject.lower_day_grade unless subject.elective_group_id.nil?
    errors["messages"] << "#{t('max_hour_exceeded_day')}" \
      if employee.max_hours_per_day <= TimetableEntry.count(:conditions => "timetable_entries.employee_id = #{employee.id} AND weekday_id = #{tte.weekday_id}",:joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0") unless employee.max_hours_per_day.nil?

    # check for max hours per week
    employee = subject.lower_week_grade unless subject.elective_group_id.nil?
    errors["messages"] << "#{t('max_hour_exceeded_week')}" \
      if employee.max_hours_per_week <= TimetableEntry.count(:conditions => "timetable_entries.employee_id = #{employee.id}",:joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0") unless employee.max_hours_per_week.nil?

    if errors["messages"].empty?
      TimetableEntry.update(tte_id, :subject_id => subject.id, :employee_id=>employee.id)
    else
      @validation_problems[tte_id] = errors
    end
  end

  @timetable = TimetableEntry.find_all_by_batch_id(@batch.id)
  render :partial => "edit_tt_multiple2"
end

def delete_employee2
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  @errors = {"messages" => []}
  tte=TimetableEntry.update(params[:id], :subject_id => nil, :employee_id => nil)
  @timetable = TimetableEntry.find_all_by_batch_id(tte.batch_id)
  render :partial => "edit_tt_multiple2", :with => @timetable
end

def tt_entry_update2
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  @errors = {"messages" => []}
  subject = Subject.find(params[:sub_id])
  tte = TimetableEntry.find(params[:tte_id])
  overlapped_tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_employee_id(tte.weekday_id,tte.class_timing_id,params[:emp_id])
  if overlapped_tte.nil?
    TimetableEntry.update(params[:tte_id], :subject_id => params[:sub_id], :employee_id => params[:emp_id])
  else
    TimetableEntry.update(overlapped_tte.id,:subject_id => nil, :employee_id => nil )
    TimetableEntry.update(params[:tte_id], :subject_id => params[:sub_id], :employee_id => params[:emp_id])
  end
  @timetable = TimetableEntry.find_all_by_batch_id(subject.batch_id)
  render :partial => "edit_tt_multiple2", :with => @timetable
end

def tt_entry_noupdate2
  render :update => "error_div_#{params[:tte_id]}", :text => "#{t('cancelled')}"
end
#PDF Reports
def timetable_pdf
  @batch = Batch.find(params[:course_id])
  @timetable = TimetableEntry.find_all_by_batch_id(@batch.id)
  @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
  if @class_timing.empty?
    @class_timing = ClassTiming.default
  end
  @day = Weekday.find_all_by_batch_id(@batch.id)
  if @day.empty?
    @day = Weekday.default
  end
  @subjects = Subject.find_all_by_batch_id(@batch.id)
  @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  render :pdf=>'timetable_pdf'
          

  #  respond_to do |format|
  #    format.pdf { render :layout => false }
  #  end
end
end
