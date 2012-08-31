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

class TimetableEntriesController < ApplicationController
  before_filter :login_required
  filter_access_to :all

  def new
    @timetable=Timetable.find(params[:timetable_id])
    
    @batches = Batch.active
  end

  def select_batch
    @timetable=Timetable.find(params[:timetable_id])
    @batches = Batch.active
    if request.post?
      unless params[:timetable_entry][:batch_id].empty?

      else
        flash[:notice]="#{t('select_a_batch_to_continue')}"
        redirect_to :action => "select_batch"
      end
    end
  end

  def new_entry
    @timetable=Timetable.find(params[:timetable_id])
    if params[:batch_id] == ""
      render :update do |page|
        page.replace_html "render_area", :text => ""
      end
      return
    end
    @batch = Batch.find(params[:batch_id])
    tte_from_batch_and_tt(@timetable.id)
    #    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
    render :update do |page|
      page.replace_html "render_area", :partial => "new_entry"
    end
  end

  def update_employees
    #    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
    if params[:subject_id] == ""
      render :text => ""
      return
    end
    @employees_subject = EmployeesSubject.find_all_by_subject_id(params[:subject_id])
    render :partial=>"employee_list"
  end

  def delete_employee2
    @errors = {"messages" => []}
    tte=TimetableEntry.find(params[:id])
    batch=tte.batch_id
    #    @timetable = TimetableEntry.find_all_by_batch_id(tte.batch_id)
    @batch=Batch.find batch
    @timetable=Timetable.find(tte.timetable_id)
    tte.destroy
    tte_from_batch_and_tt(@timetable.id)
    render :partial => "new_entry", :batch_id=>batch
  end

  #  for script

  def update_multiple_timetable_entries2
    @timetable=Timetable.find(params[:timetable_id])
    employees_subject = EmployeesSubject.find(params[:emp_sub_id])
    tte_ids = params[:tte_ids].split(",").each {|x| x}
    @batch = employees_subject.subject.batch
    subject = employees_subject.subject
    employee = employees_subject.employee
    @validation_problems = {}
    puts params[:tte_ids].inspect
    puts tte_ids.inspect
    puts @timetable.inspect
    tte_ids.each do |tte_id|
      co_ordinate=tte_id.split("_")
      weekday=co_ordinate[0].to_i
      class_timing=co_ordinate[1].to_i
      #      tte = TimetableEntry.find(tte_id)
      tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_batch_id_and_timetable_id(weekday,class_timing,@batch.id,@timetable.id)
      errors = { "info" => {"sub_id" => employees_subject.subject_id, "emp_id"=> employees_subject.employee_id,"tte_id" => tte_id},
        "messages" => [] }

      # check for weekly subject limit.
      errors["messages"] << "#{t('weekly_limit_reached')}" \
        if subject.max_weekly_classes <= TimetableEntry.count(:conditions =>{:subject_id=>subject.id,:timetable_id=>@timetable.id}) unless subject.max_weekly_classes.nil?

      #check for overlapping classes
      overlap = TimetableEntry.find(:first,
        :conditions => "timetable_id=#{@timetable.id} AND weekday_id = #{weekday} AND class_timing_id = #{class_timing} AND timetable_entries.employee_id = #{employee.id}", \
          :joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0")
      unless overlap.nil?
        errors["messages"] << "#{t('class_overlap')}: #{overlap.batch.full_name}."
      end

      # check for max_hour_day exceeded
      employee = subject.lower_day_grade unless subject.elective_group_id.nil?
      errors["messages"] << "#{t('max_hour_exceeded_day')}" \
        if employee.max_hours_per_day <= TimetableEntry.count(:conditions => "timetable_entries.timetable_id=#{@timetable.id} AND timetable_entries.employee_id = #{employee.id} AND weekday_id = #{weekday}",:joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0") unless employee.max_hours_per_day.nil?

      # check for max hours per week
      employee = subject.lower_week_grade unless subject.elective_group_id.nil?
      errors["messages"] << "#{t('max_hour_exceeded_week')}" \
        if employee.max_hours_per_week <= TimetableEntry.count(:conditions => "timetable_entries.timetable_id=#{@timetable.id} AND timetable_entries.employee_id = #{employee.id}",:joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0") unless employee.max_hours_per_week.nil?

      if errors["messages"].empty?
        unless tte.nil?
          TimetableEntry.update(tte.id, :subject_id => subject.id, :employee_id=>employee.id,:timetable_id=>@timetable.id)
        else
          TimetableEntry.new(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => subject.id, :employee_id=>employee.id,:batch_id=>@batch.id,:timetable_id=>@timetable.id).save
        end
      else
        @validation_problems[tte_id] = errors
      end
    end

    #    @timetable = TimetableEntry.find_all_by_batch_id(@batch.id)
    tte_from_batch_and_tt(@timetable.id)
    render :partial => "new_entry"
  end

  def tt_entry_update2
    @errors = {"messages" => []}
    @timetable=Timetable.find(params[:timetable_id])
    @batch=Batch.find(params[:batch_id])
    subject = Subject.find(params[:sub_id])
    co_ordinate=params[:tte_id].split("_")
    weekday=co_ordinate[0].to_i
    class_timing=co_ordinate[1].to_i
    #      tte = TimetableEntry.find(tte_id)
    tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_batch_id_and_timetable_id(weekday,class_timing,@batch.id,@timetable.id)
    overlapped_tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_employee_id_and_timetable_id(weekday,class_timing,params[:emp_id],@timetable.id)
    if overlapped_tte.nil?
      unless tte.nil?
        TimetableEntry.update(tte.id, :subject_id => params[:sub_id], :employee_id => params[:emp_id])
      else
        TimetableEntry.new(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => params[:sub_id], :employee_id => params[:emp_id],:batch_id=>@batch.id,:timetable_id=>@timetable.id).save
      end
    else
      overlapped_tte.destroy
      unless tte.nil?
        TimetableEntry.update(tte.id, :subject_id => params[:sub_id], :employee_id => params[:emp_id])
      else
        TimetableEntry.new(:weekday_id=>weekday,:class_timing_id=>class_timing, :subject_id => params[:sub_id], :employee_id => params[:emp_id],:batch_id=>@batch.id,:timetable_id=>@timetable.id).save
      end
      #      TimetableEntry.update(params[:tte_id], :subject_id => params[:sub_id], :employee_id => params[:emp_id])
    end
    
    tte_from_batch_and_tt(@timetable.id)
    render :update do |page|
      page.replace_html "box", :partial=> "timetable_box"
      page.replace_html "subjects-select", :partial=> "employee_select"
      page.replace_html "error_div_#{params[:tte_id]}", :text => "#{t('done')}"
    end
#    render :partial => "new_entry"
  end

  def tt_entry_noupdate2
    render :update => "error_div_#{params[:tte_id]}", :text => "#{t('cancelled')}"
  end



  #  for script

  private

  def tte_from_batch_and_tt(tt)
    @tt=Timetable.find(tt)
    @class_timing = ClassTiming.for_batch(@batch.id)
    if @class_timing.empty?
      @class_timing = ClassTiming.default
    end
    @weekday = Weekday.for_batch(@batch.id)
    if @weekday.empty?
      @weekday = Weekday.default
    end
    timetable_entries=TimetableEntry.find(:all,:conditions=>{:batch_id=>@batch.id,:timetable_id=>@tt.id},:include=>[:subject,:employee])
    @timetable= Hash.new { |h, k| h[k] = Hash.new(&h.default_proc)}
    timetable_entries.each do |tte|
      @timetable[tte.weekday_id][tte.class_timing_id]=tte
    end
    @subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>["elective_group_id IS NULL AND is_deleted = false"])
    @ele_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>["elective_group_id IS NOT NULL AND is_deleted = false"], :group => "elective_group_id")
  end

end
