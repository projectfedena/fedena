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
      unless @timetable.start_date>=Date.today
        @error=true
        @timetable.errors.add_to_base('start_date_is_lower_than_today')
      end
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
        new_start = Date.civil(params[:timetable][:"start_date(1i)"].to_i,params[:timetable][:"start_date(2i)"].to_i,params[:timetable][:"start_date(3i)"].to_i)
      else
        new_start=@tt.start_date
      end
      new_end = Date.civil(params[:timetable][:"end_date(1i)"].to_i,params[:timetable][:"end_date(2i)"].to_i,params[:timetable][:"end_date(3i)"].to_i)
      if new_end<new_start
        @error=true
        @timetable.errors.add_to_base('start_date_is_lower_than_today')
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
            unless new_end==Date.today
              @tt2=Timetable.new
              @tt2.start_date=1.day.from_now.to_date
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
    @timetables=Timetable.find(:all,:conditions=>["end_date > ?",Date.today])
  end

  def teachers_timetable
    @timetables=Timetable.all
    ## Prints out timetable of all teachers
    @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",Date.today,Date.today])
    @timetable_entries = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
    @all_timetable_entries = @current.timetable_entries.select{|t| t.batch.is_active}
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
  end
  #    if request.xhr?
  def update_teacher_tt
    if params[:timetable_id].nil?
      @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",Date.today,Date.today])
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
    @all_timetable_entries = @current.timetable_entries.select{|t| t.batch.is_active}
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
    timetable_entries=TimetableEntry.find(:all,:conditions=>{:batch_id=>@batch.id,:timetable_id=>@tt.id},:include=>[:subject,:employee])
    @timetable= Hash.new { |h, k| h[k] = Hash.new(&h.default_proc)}
    timetable_entries.each do |tte|
      @timetable[tte.weekday_id][tte.class_timing_id]=tte
    end
    @subjects = Subject.find_all_by_batch_id(@batch.id)  #, :conditions=>["elective_group_id IS NULL AND is_deleted = false"])
    @ele_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>["elective_group_id IS NOT NULL AND is_deleted = false"], :group => "elective_group_id")


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
    end
    unless @blocked

      @timetables=Timetable.all
      ## Prints out timetable of all teachers
      @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",Date.today,Date.today])
      unless @current.nil?
        @timetable_entries = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
        @employee_subjects = @employee.subjects
        @employee_timetable_subjects = @employee_subjects.map {|sub| sub.elective_group_id.nil? ? sub : sub.elective_group.subjects.first}
        @all_timetable_entries = @current.timetable_entries.find(:all,:conditions=>{:subject_id=>@employee_timetable_subjects})
        @all_batches = @all_timetable_entries.collect(&:batch).uniq.sort!{|a,b| a.class_timing <=> b.class_timing}
        @all_weekdays = @all_timetable_entries.collect(&:weekday).uniq.sort!{|a,b| a.weekday <=> b.weekday}
        @all_classtimings = @all_timetable_entries.collect(&:class_timing).uniq
        @all_teachers = @all_timetable_entries.collect(&:employee).uniq
        @all_timetable_entries.each do |tt|
          @timetable_entries[tt.employee_id][tt.weekday_id][tt.class_timing_id] = tt
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
      @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",Date.today,Date.today])
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
    @all_timetable_entries = @current.timetable_entries.find(:all,:conditions=>{:subject_id=>@employee_timetable_subjects})
    @all_batches = @all_timetable_entries.collect(&:batch).uniq.sort!{|a,b| a.class_timing <=> b.class_timing}
    @all_weekdays = @all_timetable_entries.collect(&:weekday).uniq.sort!{|a,b| a.weekday <=> b.weekday}
    @all_classtimings = @all_timetable_entries.collect(&:class_timing).uniq
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
    @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",Date.today,Date.today])
    @timetable_entries = Hash.new { |l, k| l[k] = Hash.new(&l.default_proc) }
    @all_timetable_entries=@current.timetable_entries.find(:all,:conditions=>{:batch_id=>@batch.id})
    @all_weekdays = @all_timetable_entries.collect(&:weekday).uniq.sort!{|a,b| a.weekday <=> b.weekday}
    @all_classtimings = @all_timetable_entries.collect(&:class_timing).uniq
    @all_teachers = @all_timetable_entries.collect(&:employee).uniq
    @all_timetable_entries.each do |tt|
      @timetable_entries[tt.weekday_id][tt.class_timing_id] = tt
    end
  end

  def update_student_tt
    @student = Student.find(params[:id])
    @batch=@student.batch
    if params[:timetable_id].nil?
      @current=Timetable.find(:first,:conditions=>["timetables.start_date <= ? AND timetables.end_date >= ?",Date.today,Date.today])
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
    @all_timetable_entries=@current.timetable_entries.find(:all,:conditions=>{:batch_id=>@batch.id})
    @all_weekdays = @all_timetable_entries.collect(&:weekday).uniq.sort!{|a,b| a.weekday <=> b.weekday}
    @all_classtimings = @all_timetable_entries.collect(&:class_timing).uniq
    @all_teachers = @all_timetable_entries.collect(&:employee).uniq
    @all_timetable_entries.each do |tt|
      @timetable_entries[tt.weekday_id][tt.class_timing_id] = tt
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
    @employees = Employee.all(:conditions=>["employee_category_id not in (?)",admin.id],:include=>[:employee_grade,:employees_subjects])
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
      @today = Date.today
    end
  end
  #  def generate
  #    @batches = Batch.active
  #    if request.post?
  #      @batch = Batch.find params[:timetable][:batch_id]
  #      @config = Configuration.find_by_config_key('StudentAttendanceType')
  #      @start_date = @batch.start_date.to_date
  #      @end_date = @batch.end_date.to_date
  #      not_set_for_batch = Weekday.for_batch(@batch.id).empty?
  #      set = 0
  #      (@start_date..@end_date).each do |d|
  #        weekday = not_set_for_batch ? (Weekday.find_by_batch_id_and_weekday(nil,d.wday)) :  (Weekday.find_by_batch_id_and_weekday(@batch.id,d.wday))
  #        unless weekday.nil?
  #          @period = PeriodEntry.find_all_by_month_date_and_batch_id(d,@batch.id)
  #          if @period.empty?
  #            unless Event.is_a_holiday?(d)
  #              unless @config.config_value == 'Daily'
  #                entries = TimetableEntry.find_all_by_weekday_id_and_batch_id(weekday.id, @batch.id)
  #                entries.each do |tte|
  #                  if tte.subject.nil?
  #                    PeriodEntry.create(:month_date=> d, :batch_id => @batch.id,:class_timing_id => tte.class_timing_id, :employee_id => tte.employee_id)
  #                  elsif tte.subject.elective_group_id.nil?
  #                    PeriodEntry.create(:month_date=> d, :batch_id => @batch.id, :subject_id => tte.subject_id, :class_timing_id => tte.class_timing_id, :employee_id => tte.employee_id)
  #                  else
  #                    sub = Subject.find_all_by_elective_group_id_and_batch_id(tte.subject.elective_group_id, @batch.id)
  #                    sub.each do |s|
  #                      PeriodEntry.create(:month_date=> d, :batch_id => @batch.id, :subject_id => s.id, :class_timing_id => tte.class_timing_id, :employee_id => tte.employee_id)
  #                    end
  #                  end
  #                end
  #                set = 2
  #              else
  #                PeriodEntry.create(:month_date=> d, :batch_id => @batch.id)
  #                set = 2
  #              end
  #            end
  #          else
  #            if @config.config_value == "SubjectWise"
  #              if d >= Date.today
  #                entries = TimetableEntry.find_all_by_weekday_id_and_batch_id(weekday.id, @batch.id)
  #                entries.each do |tte|
  #                  @period.each do |p|
  #                    if tte.class_timing_id == p.class_timing_id
  #                      unless tte.subject_id == p.subject_id
  #                        PeriodEntry.update(p.id, :month_date=> d, :batch_id => @batch.id, :subject_id => tte.subject_id, :class_timing_id =>tte.class_timing_id, :employee_id => tte.employee_id)
  #                        set = 1
  #                      end
  #                    end
  #                  end
  #
  #                end
  #              end
  #            end
  #          end
  #        end
  #
  #        if set == 0
  #          flash[:notice] = "#{t('flash1')}"
  #        elsif set == 1
  #          flash[:notice] = "#{t('flash2')}"
  #        else
  #          flash[:notice] = "#{t('flash3')}"
  #        end
  #      end
  #
  #      @config = Configuration.available_modules
  #      if @config.include?('HR')
  #        redirect_to :action=>"edit2", :id => @batch.id
  #      else
  #        redirect_to :action=>"edit", :id => @batch.id
  #      end
  #    end
  #  end
  #
  #  def extra_class
  #    @config = Configuration.available_modules
  #    unless   params[:extra_class].nil?
  #      @date = params[:extra_class][:date].to_date
  #      @batch = Batch.find(params[:extra_class][:batch_id])
  #      @period_entry = PeriodEntry.find_all_by_month_date_and_batch_id(@date,@batch.id)
  #      render (:update) do |page|
  #        if @period_entry.blank?
  #          flash[:notice] = "#{t('flash_msg16')}"
  #          page.replace_html 'extra-class-form', :partial=>"no_period_entry"
  #        else
  #          page.replace_html 'extra-class-form', :partial => "extra_class_form"
  #        end
  #      end
  #    end
  #
  #  end
  #  def extra_class_edit
  #    @config = Configuration.available_modules
  #    @period_id = params[:id]
  #    @period_entry = PeriodEntry.find(@period_id)
  #    @subjects = Subject.find_all_by_batch_id(@period_entry.batch_id,:conditions=>'is_deleted=false')
  #    @employee = EmployeesSubject.find_all_by_subject_id(@period_entry.subject_id)
  #  end
  #  def list_employee_by_subject
  #    @period_id = params[:period_id]
  #    @subject = Subject.find(params[:subject_id])
  #    @employee = EmployeesSubject.find_all_by_subject_id(@subject.id)
  #    render (:update) do |page|
  #      page.replace_html "employee-update-#{@period_id}", :partial => "list_employee_by_subject"
  #    end
  #  end
  #  def save_extra_class
  #    @period = PeriodEntry.find(params[:period_entry][:period_id])
  #    PeriodEntry.update(@period.id, :subject_id => params[:period_entry][:subject_id], :employee_id => params[:period_entry][:employee_id])
  #    @period = PeriodEntry.find(params[:period_entry][:period_id])
  #    render (:update) do |page|
  #      page.replace_html "tr-extra-class-#{@period.id}", :partial => 'extra_class_update'
  #    end
  #  end
  #
  #
  #  def delete_subject
  #    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  #    @errors = {"messages" => []}
  #    tte = TimetableEntry.update(params[:id], :subject_id => nil)
  #    @timetable = TimetableEntry.find_all_by_batch_id(tte.batch_id)
  #    render :partial => "edit_tt_multiple", :with => @timetable
  #  end
  #
  #  #    def edit
  #  #      @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  #  #      @errors = {"messages" => []}
  #  #      @batch = Batch.find(params[:id])
  #  #      @timetable = TimetableEntry.find_all_by_batch_id(params[:id])
  #  #      @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
  #  #      if @class_timing.empty?
  #  #        @class_timing = ClassTiming.default
  #  #      end
  #  #      @day = Weekday.find_all_by_batch_id(@batch.id)
  #  #      if @day.empty?
  #  #        @day = Weekday.default
  #  #      end
  #  #      @subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>["elective_group_id IS NULL AND is_deleted = false"])
  #  #    end
  #
  #  def select_class
  #    @batches = Batch.active
  #    if request.post?
  #      unless params[:timetable_entry][:batch_id].empty?
  #        @batch = Batch.find(params[:timetable_entry][:batch_id])
  #        @class_timings = ClassTiming.find_all_by_batch_id(@batch.id)
  #        if @class_timings.empty?
  #          @class_timings = ClassTiming.default
  #        end
  #        @days = Weekday.find_all_by_batch_id(@batch.id)
  #        if @days.empty?
  #          @days = Weekday.default
  #        end
  #        @days.each do |d|
  #          @class_timings.each do |p|
  #            TimetableEntry.create(:batch_id=>@batch.id, :weekday_id => d.id, :class_timing_id => p.id) \
  #              if TimetableEntry.find_by_batch_id_and_weekday_id_and_class_timing_id(@batch.id, d.id, p.id).nil?
  #          end
  #        end
  #
  #        redirect_to :action => "edit", :id => @batch.id
  #      else
  #        flash[:notice]="#{t('select_a_batch_to_continue')}"
  #        redirect_to :action => "select_class"
  #      end
  #    end
  #  end


  #  def tt_entry_update
  #    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  #    @errors = {"messages" => []}
  #    subject = Subject.find(params[:sub_id])
  #    TimetableEntry.update(params[:tte_id], :subject_id => params[:sub_id])
  #    @timetable = TimetableEntry.find_all_by_batch_id(subject.batch_id)
  #    render :partial => "edit_tt_multiple", :with => @timetable
  #  end
  #
  #  def tt_entry_noupdate
  #    render :update => "error_div_#{params[:tte_id]}", :text => "#{t('cancelled')}"
  #  end
  #
  #  def update_multiple_timetable_entries
  #    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  #    subject = Subject.find(params[:subject_id])
  #    tte_ids = params[:tte_ids].split(",").each {|x| x.to_i}
  #    course = subject.batch
  #    @validation_problems = {}
  #
  #    tte_ids.each do |tte_id|
  #      errors = { "info" => {"sub_id" => subject.id, "tte_id" => tte_id},
  #        "messages" => [] }
  #
  #      # check for weekly subject limit.
  #      errors["messages"] << "#{t('weekly_limit_reached')}" \
  #        if subject.max_weekly_classes <= TimetableEntry.count(:conditions => "subject_id = #{subject.id}")
  #
  #      if errors["messages"].empty?
  #        TimetableEntry.update(tte_id, :subject_id => subject.id)
  #      else
  #        @validation_problems[tte_id] = errors
  #      end
  #    end
  #
  #    @timetable = TimetableEntry.find_all_by_batch_id(course.id)
  #    render :partial => "edit_tt_multiple", :with => @timetable
  #  end


  

  #methods given below are for timetable with HR module connected

  #  def select_class2
  #    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  #    @batches = Batch.active
  #    if request.post?
  #      unless params[:timetable_entry][:batch_id].empty?
  #        @batch = Batch.find(params[:timetable_entry][:batch_id])
  #        @class_timings = ClassTiming.find_all_by_batch_id(@batch.id, :conditions => "is_break = false")
  #        if @class_timings.empty?
  #          @class_timings = ClassTiming.default
  #        end
  #        @day = Weekday.find_all_by_batch_id(@batch.id)
  #        if @day.empty?
  #          @day = Weekday.default
  #        end
  #        @day.each do |d|
  #          @class_timings.each do |p|
  #            TimetableEntry.create(:batch_id=>@batch.id, :weekday_id => d.id, :class_timing_id => p.id) \
  #              if TimetableEntry.find_by_batch_id_and_weekday_id_and_class_timing_id(@batch.id, d.id, p.id).nil?
  #          end
  #        end
  #        redirect_to :action => "edit2", :id => @batch.id
  #      else
  #        flash[:notice]="#{t('select_a_batch_to_continue')}"
  #        redirect_to :action => "select_class2"
  #      end
  #    end
  #  end
  #
  #  def edit2
  #    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  #    @errors = {"messages" => []}
  #    @batch = Batch.find(params[:id])
  #    @timetable = TimetableEntry.find_all_by_batch_id(params[:id])
  #    @class_timing = ClassTiming.find_all_by_batch_id(@batch.id, :conditions =>[ "is_break = false"], :order =>'start_time ASC')
  #    if @class_timing.empty?
  #      @class_timing = ClassTiming.default
  #    end
  #    @day = Weekday.find_all_by_batch_id(@batch.id)
  #    if @day.empty?
  #      @day = Weekday.default
  #    end
  #    @subjects = Subject.find_all_by_batch_id(@batch.id)
  #  end
  #
  #  def update_employees
  #    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  #    if params[:subject_id] == ""
  #      render :text => ""
  #      return
  #    end
  #    @employees_subject = EmployeesSubject.find_all_by_subject_id(params[:subject_id])
  #    render :partial=>"employee_list"
  #  end
  #
  #  def update_multiple_timetable_entries2
  #    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  #    employees_subject = EmployeesSubject.find(params[:emp_sub_id])
  #    tte_ids = params[:tte_ids].split(",").each {|x| x.to_i}
  #    @batch = employees_subject.subject.batch
  #    subject = employees_subject.subject
  #    employee = employees_subject.employee
  #    @validation_problems = {}
  #
  #    tte_ids.each do |tte_id|
  #      tte = TimetableEntry.find(tte_id)
  #      errors = { "info" => {"sub_id" => employees_subject.subject_id, "emp_id"=> employees_subject.employee_id,"tte_id" => tte_id},
  #        "messages" => [] }
  #
  #      # check for weekly subject limit.
  #      errors["messages"] << "#{t('weekly_limit_reached')}" \
  #        if subject.max_weekly_classes <= TimetableEntry.count(:conditions => "subject_id = #{subject.id}") unless subject.max_weekly_classes.nil?
  #
  #      #check for overlapping classes
  #      overlap = TimetableEntry.find(:first,
  #        :conditions => "weekday_id = #{tte.weekday_id} AND class_timing_id = #{tte.class_timing_id} AND timetable_entries.employee_id = #{employee.id}", \
  #          :joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0")
  #      unless overlap.nil?
  #        errors["messages"] << "#{t('class_overlap')}: #{overlap.batch.full_name}."
  #      end
  #
  #      # check for max_hour_day exceeded
  #      employee = subject.lower_day_grade unless subject.elective_group_id.nil?
  #      errors["messages"] << "#{t('max_hour_exceeded_day')}" \
  #        if employee.max_hours_per_day <= TimetableEntry.count(:conditions => "timetable_entries.employee_id = #{employee.id} AND weekday_id = #{tte.weekday_id}",:joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0") unless employee.max_hours_per_day.nil?
  #
  #      # check for max hours per week
  #      employee = subject.lower_week_grade unless subject.elective_group_id.nil?
  #      errors["messages"] << "#{t('max_hour_exceeded_week')}" \
  #        if employee.max_hours_per_week <= TimetableEntry.count(:conditions => "timetable_entries.employee_id = #{employee.id}",:joins=>"INNER JOIN subjects ON timetable_entries.subject_id = subjects.id INNER JOIN batches ON subjects.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0") unless employee.max_hours_per_week.nil?
  #
  #      if errors["messages"].empty?
  #        TimetableEntry.update(tte_id, :subject_id => subject.id, :employee_id=>employee.id)
  #      else
  #        @validation_problems[tte_id] = errors
  #      end
  #    end
  #
  #    @timetable = TimetableEntry.find_all_by_batch_id(@batch.id)
  #    render :partial => "edit_tt_multiple2"
  #  end
  #
  #  def delete_employee2
  #    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  #    @errors = {"messages" => []}
  #    tte=TimetableEntry.update(params[:id], :subject_id => nil, :employee_id => nil)
  #    @timetable = TimetableEntry.find_all_by_batch_id(tte.batch_id)
  #    render :partial => "edit_tt_multiple2", :with => @timetable
  #  end
  #
  #  def tt_entry_update2
  #    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
  #    @errors = {"messages" => []}
  #    subject = Subject.find(params[:sub_id])
  #    tte = TimetableEntry.find(params[:tte_id])
  #    overlapped_tte = TimetableEntry.find_by_weekday_id_and_class_timing_id_and_employee_id(tte.weekday_id,tte.class_timing_id,params[:emp_id])
  #    if overlapped_tte.nil?
  #      TimetableEntry.update(params[:tte_id], :subject_id => params[:sub_id], :employee_id => params[:emp_id])
  #    else
  #      TimetableEntry.update(overlapped_tte.id,:subject_id => nil, :employee_id => nil )
  #      TimetableEntry.update(params[:tte_id], :subject_id => params[:sub_id], :employee_id => params[:emp_id])
  #    end
  #    @timetable = TimetableEntry.find_all_by_batch_id(subject.batch_id)
  #    render :partial => "edit_tt_multiple2", :with => @timetable
  #  end
  #
  #  def tt_entry_noupdate2
  #    render :update => "error_div_#{params[:tte_id]}", :text => "#{t('cancelled')}"
  #  end
  #PDF Reports
  
  
end
class Hash
  def delete_blank
    delete_if{|k, v| v.empty? or v.instance_of?(Hash) && v.delete_blank.empty?}
  end
end