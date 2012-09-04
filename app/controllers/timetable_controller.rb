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
  before_filter :default_time_zone_present_time
  filter_access_to :all

  def new_timetable

    if request.post?
      @timetable=Timetable.new(params[:timetable])
      @error=false
      previous=Timetable.find(:all,:conditions=>["end_date >= ? AND start_date <= ?",@timetable.start_date,@timetable.start_date])
      unless previous.empty?
        @error=true
        @timetable.errors.add_to_base('start_date_overlap')
      end
      conflicts=Timetable.find(:all,:conditions=>["end_date >= ? AND start_date <= ?",@timetable.end_date,@timetable.end_date])
      unless conflicts.empty?
        @error=true
        @timetable.errors.add_to_base('end_date_overlap')
      end
      #      unless @timetable.start_date>=Date.today
      #        @error=true
      #        @timetable.errors.add_to_base('start_date_is_lower_than_today')
      #      end
      if @timetable.start_date > @timetable.end_date
        @error=true
        @timetable.errors.add_to_base('start_date_is_lower_than_end_date')
      end
      unless @error
        if @timetable.save
          flash[:notice]="#{t('timetable_created_from')} #{@timetable.start_date} - #{@timetable.end_date}"
          redirect_to :controller=>:timetable_entries,:action => "new",:timetable_id=>@timetable.id
        else
          flash[:notice]='error_occured'
          render :action=>'new_timetable'
        end
      else
        flash[:warn_notice]=@timetable.errors.full_messages unless @timetable.errors.empty?
        render :action=>'new_timetable'
      end
    end
  end

  def update_timetable
    @timetable=Timetable.find(params[:id])
    @current=false
    if (@timetable.start_date <= Date.today and @timetable.end_date >= Date.today)
      @current=true
    end
    if (@timetable.start_date > Date.today and @timetable.end_date > Date.today)
      @removable=true
    end
    if request.post?
      @tt=Timetable.find(params[:id])
      @error=false
      if params[:timetable][:"start_date(1i)"].present?
        date_start=[params[:timetable][:"start_date(1i)"].to_i,params[:timetable][:"start_date(2i)"].to_i,params[:timetable][:"start_date(3i)"].to_i]
        unless Date::valid_date?(date_start[0],date_start[1],date_start[2]).nil?
          new_start = Date.civil(date_start[0],date_start[1],date_start[2])
        else
          @timetable.errors.add_to_base('start_date_is_invalid')
          @error=true
          new_start=@tt.start_date
        end
      else
        new_start=@tt.start_date
      end
      if params[:timetable][:"end_date(1i)"].present?
        date_end=[params[:timetable][:"end_date(1i)"].to_i,params[:timetable][:"end_date(2i)"].to_i,params[:timetable][:"end_date(3i)"].to_i]
        unless Date::valid_date?(date_end[0],date_end[1],date_end[2]).nil?
          new_end = Date.civil(date_end[0],date_end[1],date_end[2])
        else
          @timetable.errors.add_to_base('end_date_is_invalid')
          @error=true
          new_end=@tt.end_date
        end
      else
        new_end=@tt.end_date
      end
      if new_end<new_start
        @error=true
        @timetable.errors.add_to_base('start_date_is_lower_than_end_date')
      end
      if new_end < Date.today
        @error=true
        @timetable.errors.add_to_base('end_date_is_lower_than_today')
      end
      #      @end_conflicts=Timetable.find(:all,:conditions=>["start_date <= ? AND id != ?",new_end,@tt.id])
      @end_conflicts=Timetable.find(:all,:conditions=>["start_date <= ? AND end_date >= ? AND id != ?",new_end,new_start,@tt.id])
      unless @end_conflicts.empty?
        @error=true
        @timetable.errors.add_to_base('end_date_overlap')
      end
      unless @current
        if new_start<=Date.today
          @timetable.errors.add_to_base('start_date_is_lower_than_today')
          @error=true
        end
      end
      unless @error
        if (@tt.start_date <= Date.today and @tt.end_date >= Date.today)
          @tt.end_date=Date.today
          if @tt.save
            unless new_end<=Date.today
              @tt2=Timetable.new
              @tt2.start_date=Date.today+1.days
              @tt2.end_date=new_end
              if @tt2.save
                entries=@tt.timetable_entries
                entries.each do |e|
                  entry2=e.clone
                  entry2.timetable_id=@tt2.id
                  entry2.save
                end
              end
              flash[:notice]=t('timetable_updated')
              redirect_to :controller=>:timetable_entries,:action => "new",:timetable_id=>@tt2.id
            else
              flash[:notice]=t('timetable_updated')
              redirect_to :controller=>:timetable,:action=>:edit_master
            end
          else
            flash[:warn_notice]=@timetable.errors.full_messages unless @timetable.errors.empty?
            render :action => "new_timetable"
          end
        else
          if @tt.update_attributes(params[:timetable])
            flash[:notice]=t('timetable_updated')
            redirect_to :controller=>"timetable",:action => "edit_master"
          else
            @timetable.errors.add_to_base("timetable_update_failure")
            @error=true
            flash[:notice]=t('timetable_update_failure')
          end
        end
      else
        flash[:warn_notice]=@timetable.errors.full_messages unless @timetable.errors.empty?
        #        redirect_to :controller=>"timetable",:action => "update_timetable",:id=>@timetable.id
        render :action => "update_timetable"#,:id=>@timetable.id
      end
    end
  end

  def view
    @courses = Batch.active
    @timetables=Timetable.all
  end

  def edit_master
    @courses = Batch.active
    @timetables=Timetable.find(:all,:conditions=>["end_date > ?",@local_tzone_time.to_date])
  end

  def teachers_timetable
    @timetables=Timetable.all
    ## Prints out timetable of all teachers
    @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",@local_tzone_time.to_date,@local_tzone_time.to_date])
    if @current
      @timetable_entries = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
      @all_timetable_entries = @current.timetable_entries.select{|t| t.batch.is_active}.select{|s| s.class_timing.is_deleted==false}.select{|w| w.weekday.is_deleted==false}
      @all_batches = @all_timetable_entries.collect(&:batch).uniq#.sort!{|a,b| a.class_timing <=> b.class_timing}
      @all_weekdays = @all_timetable_entries.collect(&:weekday).uniq.sort!{|a,b| a.weekday <=> b.weekday}
      @all_classtimings = @all_timetable_entries.collect(&:class_timing).uniq.sort!{|a,b| a.start_time <=> b.start_time}
      @all_subjects = @all_timetable_entries.collect(&:subject).uniq
      @all_teachers = @all_timetable_entries.collect(&:employee).uniq
      @all_timetable_entries.each do |tt|
        @timetable_entries[tt.employee_id][tt.weekday_id][tt.class_timing_id] = tt
      end
      @all_subjects.each do |sub|
        unless sub.elective_group.nil?
          @all_teachers+=sub.elective_group.subjects.collect(&:employees).flatten
          @elective_teachers=sub.elective_group.subjects.collect(&:employees).flatten
          @current.timetable_entries.find_all_by_subject_id(sub.id).each do |tt|
            @elective_teachers.each do |e|
              @timetable_entries[e.id][tt.weekday_id][tt.class_timing_id] = tt
            end
          end
        end
      end
      @all_teachers=@all_teachers.uniq
    else
      @all_timetable_entries=[]
    end
  end
  #    if request.xhr?
  def update_teacher_tt
    if params[:timetable_id].nil?
      @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",@local_tzone_time.to_date,@local_tzone_time.to_date])
    else
      if params[:timetable_id]==""
        render :update do |page|
          page.replace_html "timetable_view", :text => ""
        end
        return
      else
        @current=Timetable.find(params[:timetable_id])
      end
    end
    @timetable_entries = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
    @all_timetable_entries = @current.timetable_entries.select{|t| t.batch.is_active}.select{|s| s.class_timing.is_deleted==false}.select{|w| w.weekday.is_deleted==false}
    @all_batches = @all_timetable_entries.collect(&:batch).uniq#.sort!{|a,b| a.class_timing <=> b.class_timing}
    @all_weekdays = @all_timetable_entries.collect(&:weekday).uniq.sort!{|a,b| a.weekday <=> b.weekday}
    @all_classtimings = @all_timetable_entries.collect(&:class_timing).uniq.sort!{|a,b| a.start_time <=> b.start_time}
    @all_subjects = @all_timetable_entries.collect(&:subject).uniq
    @all_teachers = @all_timetable_entries.collect(&:employee).uniq
    @all_timetable_entries.each do |tt|
      @timetable_entries[tt.employee_id][tt.weekday_id][tt.class_timing_id] = tt
    end
    @all_subjects.each do |sub|
      unless sub.elective_group.nil?
        @all_teachers+=sub.elective_group.subjects.collect(&:employees).flatten
        @elective_teachers=sub.elective_group.subjects.collect(&:employees).flatten
        @current.timetable_entries.find_all_by_subject_id(sub.id).each do |tt|
          @elective_teachers.each do |e|
            @timetable_entries[e.id][tt.weekday_id][tt.class_timing_id] = tt
          end
        end
      end
    end
    @all_teachers=@all_teachers.uniq
    render :update do |page|
      page.replace_html "timetable_view", :partial => "teacher_timetable"
    end
  end

  def update_timetable_view
    if  (params[:course_id] == "" || params[:timetable_id] == "")
      render :update do |page|
        page.replace_html "timetable_view", :text => ""
      end
      return
    end
    @batch = Batch.find(params[:course_id])
    @tt = Timetable.find(params[:timetable_id])
    @timetable = TimetableEntry.find_all_by_batch_id_and_timetable_id(@batch.id,@tt.id)
    if @timetable.empty?
      render :update do |page|
        page.replace_html "timetable_view", :text => ""
      end
      return
    end
    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
    @class_timing = ClassTiming.for_batch(@batch.id)
    if @class_timing.empty?
      @class_timing = ClassTiming.default
    end
    @day = Weekday.for_batch(@batch.id)
    if @day.empty?
      @day = Weekday.default
    end
    @timetable_entries=TimetableEntry.find(:all,:conditions=>{:batch_id=>@batch.id,:timetable_id=>@tt.id},:include=>[:subject,:employee])
    @timetable= Hash.new { |h, k| h[k] = Hash.new(&h.default_proc)}
    @timetable_entries.each do |tte|
      @timetable[tte.weekday_id][tte.class_timing_id]=tte
    end

    render :update do |page|
      page.replace_html "timetable_view", :partial => "view_timetable"
    end
  end

  def destroy
    @timetable=Timetable.find(params[:id])
    if @timetable.destroy
      flash[:notice]=t('timetable_deleted')
      redirect_to :controller=>:timetable
    end
  end

  def employee_timetable
    @employee=Employee.find(params[:id])
    @blocked=true
    if permitted_to? :employee_timetable,:timetables
      @blocked=false
    elsif @current_user.employee_record==@employee
      @blocked=false
    elsif @current_user.admin?
      @blocked=false
    end
    unless @blocked

      @timetables=Timetable.all
      ## Prints out timetable of all teachers
      @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",@local_tzone_time.to_date,@local_tzone_time.to_date])
      unless @current.nil?
        @electives=@employee.subjects.group_by(&:elective_group_id)
        @timetable_entries = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
        @employee_subjects = @employee.subjects
        @employee_timetable_subjects = @employee_subjects.map {|sub| sub.elective_group_id.nil? ? sub : sub.elective_group.subjects.first}
        @entries = @current.timetable_entries.find(:all,:conditions=>{:subject_id=>@employee_timetable_subjects})
        @all_timetable_entries = @entries.select{|t| t.batch.is_active}.select{|s| s.class_timing.is_deleted==false}.select{|w| w.weekday.is_deleted==false}
        @all_batches = @all_timetable_entries.collect(&:batch).uniq
        @all_weekdays = @all_timetable_entries.collect(&:weekday).uniq.sort!{|a,b| a.weekday <=> b.weekday}
        @all_classtimings = @all_timetable_entries.collect(&:class_timing).uniq.sort!{|a,b| a.start_time <=> b.start_time}
        @all_teachers = @all_timetable_entries.collect(&:employee).uniq
        @all_timetable_entries.each do |tt|
          @timetable_entries[tt.weekday_id][tt.class_timing_id] = tt
        end
      else
        flash[:notice]=t('no_entries_found')
      end
    else
      flash[:notice]=t('flash_msg6')
      redirect_to :controller=>:user ,:action=>:dashboard
    end
  end

  #    if request.xhr?
  def update_employee_tt
    @employee=Employee.find(params[:employee_id])
    if params[:timetable_id].nil?
      @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",@local_tzone_time.to_date,@local_tzone_time.to_date])
    else
      if params[:timetable_id]==""
        render :update do |page|
          page.replace_html "timetable_view", :text => ""
        end
        return
      else
        @current=Timetable.find(params[:timetable_id])
      end
    end
    @electives=@employee.subjects.group_by(&:elective_group_id)
    @timetable_entries = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
    @employee_subjects = @employee.subjects
    @employee_timetable_subjects = @employee_subjects.map {|sub| sub.elective_group_id.nil? ? sub : sub.elective_group.subjects.first}
    @entries = @current.timetable_entries.find(:all,:conditions=>{:subject_id=>@employee_timetable_subjects})
    @all_timetable_entries = @entries.select{|t| t.batch.is_active}.select{|s| s.class_timing.is_deleted==false}.select{|w| w.weekday.is_deleted==false}
    @all_batches = @all_timetable_entries.collect(&:batch).uniq
    @all_weekdays = @all_timetable_entries.collect(&:weekday).uniq.sort!{|a,b| a.weekday <=> b.weekday}
    @all_classtimings = @all_timetable_entries.collect(&:class_timing).uniq.sort!{|a,b| a.start_time <=> b.start_time}
    @all_teachers = @all_timetable_entries.collect(&:employee).uniq
    @all_timetable_entries.each do |tt|
      @timetable_entries[tt.weekday_id][tt.class_timing_id] = tt
    end
    render :update do |page|
      page.replace_html "timetable_view", :partial => "employee_timetable"
    end
  end

  def student_view
    @student = Student.find(params[:id])
    @batch=@student.batch
    @timetables=Timetable.all
    @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",@local_tzone_time.to_date,@local_tzone_time.to_date])
    @timetable_entries = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
    unless @current.nil?
      @entries=@current.timetable_entries.find(:all,:conditions=>{:batch_id=>@batch.id})
      @all_timetable_entries = @entries.select{|s| s.class_timing.is_deleted==false}.select{|w| w.weekday.is_deleted==false}
      @all_weekdays = @all_timetable_entries.collect(&:weekday).uniq.sort!{|a,b| a.weekday <=> b.weekday}
      @all_classtimings = @all_timetable_entries.collect(&:class_timing).uniq
      @all_teachers = @all_timetable_entries.collect(&:employee).uniq
      @all_timetable_entries.each do |tt|
        @timetable_entries[tt.weekday_id][tt.class_timing_id] = tt
      end
    end
  end

  def update_student_tt
    @student = Student.find(params[:id])
    @batch=@student.batch
    if params[:timetable_id].nil?
      @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",@local_tzone_time.to_date,@local_tzone_time.to_date])
    else
      if params[:timetable_id]==""
        render :update do |page|
          page.replace_html "box", :text => ""
        end
        return
      else
        @current=Timetable.find(params[:timetable_id])
      end
    end
    @timetable_entries = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
    unless @current.nil?
      @entries=@current.timetable_entries.find(:all,:conditions=>{:batch_id=>@batch.id})
      @all_timetable_entries = @entries.select{|s| s.class_timing.is_deleted==false}.select{|w| w.weekday.is_deleted==false}
      @all_weekdays = @all_timetable_entries.collect(&:weekday).uniq.sort!{|a,b| a.weekday <=> b.weekday}
      @all_classtimings = @all_timetable_entries.collect(&:class_timing).uniq
      @all_teachers = @all_timetable_entries.collect(&:employee).uniq
      @all_timetable_entries.each do |tt|
        @timetable_entries[tt.weekday_id][tt.class_timing_id] = tt
      end
    end

    render :update do |page|
      page.replace_html "box", :partial => "student_timetable"
    end
  end

  def weekdays
    @batches = Batch.active
  end

  def timetable_pdf
    @batch = Batch.find(params[:course_id])
    @master = Timetable.find(params[:timetable_id])
    @timetable = TimetableEntry.find_all_by_batch_id_and_timetable_id(@batch.id,params[:timetable_id])
    @class_timing = ClassTiming.for_batch(@batch.id)
    if @class_timing.empty?
      @class_timing = ClassTiming.default
    end
    @day = Weekday.for_batch(@batch.id)
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
  def work_allotment
    admin = EmployeeCategory.find_by_prefix('admin')
    admin_ids = []
    admin_ids << admin.id unless admin.nil?
    @employees = Employee.all(:conditions=>["employee_category_id not in (?)",admin_ids],:include=>[:employee_grade,:employees_subjects])
    @emp_subs = []

    if request.post?
      params[:employee_subjects].delete_blank
      success,@error_obj = EmployeesSubject.allot_work(params[:employee_subjects])
      if success
        flash[:notice] = t('work_allotment_success')
      else
        flash[:notice] = t('updated_with_errors')
      end
    end
    @batches = Batch.active.scoped :include=>[{:subjects=>:employees},:course]
    @subjects = @batches.collect(&:subjects).flatten

    @subject_limits = {}
    @subjects.each{|s| @subject_limits[s.id] = s.max_weekly_classes}
    @employee_limits = {}
    @employees.each{|e| @employee_limits[e.id] = e.max_hours_week}
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
      @today = @local_tzone_time.to_date
    end
  end
  
end
class Hash
  def delete_blank
    delete_if{|k, v| v.empty? or v.instance_of?(Hash) && v.delete_blank.empty?}
  end
end