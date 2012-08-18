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

class AttendancesController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  before_filter :only_assigned_employee_allowed, :except => 'index'
  before_filter :only_privileged_employee_allowed, :only => 'index'
  before_filter :default_time_zone_present_time
  def index
    @date_today = @local_tzone_time.to_date
    if current_user.admin?
      @batches = Batch.active
    elsif @current_user.privileges.map{|p| p.name}.include?('StudentAttendanceRegister')
      @batches = Batch.active
    elsif @current_user.employee?
      @batches=Batch.find_all_by_employee_id @current_user.employee_record.id
      @batches+=@current_user.employee_record.subjects.collect{|b| b.batch}
      @batches=@batches.uniq unless @batches.empty?
    end
    @config = Configuration.find_by_config_key('StudentAttendanceType')
  end

  def list_subject
    @batch = Batch.find(params[:batch_id])
    @subjects = @batch.subjects
    if @current_user.employee? and @allow_access ==true and !@current_user.privileges.map{|m| m.name}.include?("StudentAttendanceRegister")
      if @batch.employee_id.to_i==@current_user.employee_record.id
        @subjects= @batch.subjects
      else
        @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      end
    end
    render(:update) do |page|
      page.replace_html 'subjects', :partial=> 'subjects'
    end
  end

  def show
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    unless params[:next].nil?
      @today = params[:next].to_date
    else
      @today = @local_tzone_time.to_date
    end
    start_date = @today.beginning_of_month
    end_date = @today.end_of_month
    if @config.config_value == 'Daily'
      @batch = Batch.find(params[:batch_id])
      @students = Student.find_all_by_batch_id(@batch.id)
      #      @dates = ((@batch.end_date.to_date > @today.end_of_month) ? (@today.beginning_of_month..@today.end_of_month) : (@today.beginning_of_month..@batch.end_date.to_date))
      @dates=@batch.working_days(@today)
    else
      @sub =Subject.find params[:subject_id]
      @batch=Batch.find(@sub.batch_id)
      unless @sub.elective_group_id.nil?
        elective_student_ids = StudentsSubject.find_all_by_subject_id(@sub.id).map { |x| x.student_id }
        @students = Student.find_all_by_batch_id(@batch, :conditions=>"FIND_IN_SET(id,\"#{elective_student_ids.split.join(',')}\")")
      else
        @students = Student.find_all_by_batch_id(@batch)
      end
      @dates=Timetable.tte_for_range(@batch,@today,@sub)
      @dates_key=@dates.keys - @batch.holiday_event_dates
    end
    respond_to do |format|
      format.js { render :action => 'show' }
    end
  end

  def subject_wise_register
    @sub =Subject.find params[:subject_id]
    @batch=Batch.find(@sub.batch_id)
    @today = params[:next].present? ? params[:next].to_date : @local_tzone_time.to_date
    unless @sub.elective_group_id.nil?
      elective_student_ids = StudentsSubject.find_all_by_subject_id(@sub.id).map { |x| x.student_id }
      @students = @batch.students.by_first_name.with_full_name_only.all(:conditions=>"FIND_IN_SET(id,\"#{elective_student_ids.split.join(',')}\")")
    else
      @students = @batch.students.by_first_name.with_full_name_only
    end
    subject_leaves = SubjectLeave.by_month_batch_subject(@today,@batch.id,@sub.id).group_by(&:student_id)
    @leaves = Hash.new
    @students.each do |student|
      @leaves[student.id] = Hash.new(false)
      unless subject_leaves[student.id].nil?
        subject_leaves[student.id].group_by(&:month_date).each do |m,mleave|
          @leaves[student.id]["#{m}"]={}
          mleave.group_by(&:class_timing_id).each do |ct,ctleave|
            ctleave.each do |leave|
              @leaves[student.id]["#{m}"][ct] = leave.id
            end
          end
        end
      end
    end
    @dates=Timetable.tte_for_range(@batch,@today,@sub)
    @translated=Hash.new
    @translated['name']=t('name')
    (0..6).each do |i|
      @translated[Date::ABBR_DAYNAMES[i].to_s]=t(Date::ABBR_DAYNAMES[i].downcase)
    end
    (1..12).each do |i|
      @translated[Date::MONTHNAMES[i].to_s]=t(Date::MONTHNAMES[i].downcase)
    end
    respond_to do |fmt|
      fmt.json {render :json=>{'leaves'=>@leaves,'students'=>@students,'dates'=>@dates,'batch'=>@batch,'today'=>@today,'translated'=>@translated}}
    end
  end

  def daily_register
    @batch = Batch.find(params[:batch_id])
    @today = params[:next].present? ? params[:next].to_date : @local_tzone_time.to_date
    @students = @batch.students.by_first_name.with_full_name_only
    @leaves = Hash.new
    attendances = Attendance.by_month_and_batch(@today,params[:batch_id]).group_by(&:student_id)
    @students.each do |student|
      @leaves[student.id] = Hash.new(false)
      unless attendances[student.id].nil?
        attendances[student.id].each do |attendance|
          @leaves[student.id]["#{attendance.month_date}"] = attendance.id
        end
      end
    end
    #    @dates=((@batch.end_date.to_date > @today.end_of_month) ? (@today.beginning_of_month..@today.end_of_month) : (@today.beginning_of_month..@batch.end_date.to_date))
    @dates=@batch.working_days(@today)
    @holidays = []
    @translated=Hash.new
    @translated['name']=t('name')
    (0..6).each do |i|
      @translated[Date::ABBR_DAYNAMES[i].to_s]=t(Date::ABBR_DAYNAMES[i].downcase)
    end
    (1..12).each do |i|
      @translated[Date::MONTHNAMES[i].to_s]=t(Date::MONTHNAMES[i].downcase)
    end
    respond_to do |fmt|
      fmt.json {render :json=>{'leaves'=>@leaves,'students'=>@students,'dates'=>@dates,'holidays'=>@holidays,'batch'=>@batch,'today'=>@today, 'translated'=>@translated}}
      #      format.js { render :action => 'show' }
    end
  end
  
  def new
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    if @config.config_value=='Daily'
      @student = Student.find(params[:id])
      @month_date = params[:date]
      @absentee = Attendance.new
    else
      @student = Student.find(params[:id]) unless params[:id].nil?
      @student ||= Student.find(params[:subject_leave][:student_id])
      @subject_leave=SubjectLeave.new
    end
    respond_to do |format|
      format.js { render :action => 'new' }
    end
  end

  def create
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    if @config.config_value=="SubjectWise"
      @student = Student.find(params[:subject_leave][:student_id])
      @tte=TimetableEntry.find(params[:timetable_entry])
      @absentee = SubjectLeave.new(params[:subject_leave])
      @absentee.subject_id=params[:subject_leave][:subject_id]
      @absentee.employee_id=@tte.employee_id
      #      @absentee.subject_id=@tte.subject_id
      @absentee.class_timing_id=@tte.class_timing_id
      @absentee.batch_id = @student.batch_id
      
    else
      @student = Student.find(params[:attendance][:student_id])
      @absentee = Attendance.new(params[:attendance])
    end
    respond_to do |format|
      if @absentee.save
        sms_setting = SmsSetting.new()
        if sms_setting.application_sms_active and @student.is_sms_enabled and sms_setting.attendance_sms_active
          recipients = []
          message = "#{@student.first_name} #{@student.last_name} #{t('flash_msg7')} #{@absentee.month_date}"
          if sms_setting.student_sms_active
            recipients.push @student.phone2 unless @student.phone2.nil?
          end
          if sms_setting.parent_sms_active
            unless @student.immediate_contact_id.nil?
              guardian = Guardian.find(@student.immediate_contact_id)
              recipients.push guardian.mobile_phone unless guardian.mobile_phone.nil?
            end
          end
          unless recipients.empty?
            Delayed::Job.enqueue(SmsManager.new(message,recipients))
          end
        end
        format.js { render :action => 'create' }
      else
        @error = true
        format.html { render :action => "new" }
        format.js { render :action => 'create' }
      end
    end
  end

  def edit
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    if @config.config_value=='Daily'
      @absentee = Attendance.find params[:id]
    else
      @absentee = SubjectLeave.find params[:id]
    end
    @student = Student.find(@absentee.student_id)
    respond_to do |format|
      format.html { }
      format.js { render :action => 'edit' }
    end
  end

  def update
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    if @config.config_value=='Daily'
      @absentee = Attendance.find params[:id]
      @student = Student.find(@absentee.student_id)
      if @absentee.update_attributes(params[:attendance])
      else
        @error = true
      end
    else
      @absentee = SubjectLeave.find params[:id]
      @student = Student.find(@absentee.student_id)
      if @absentee.update_attributes(params[:subject_leave])
      else
        @error = true
      end
    end
    respond_to do |format|
      format.js { render :action => 'update' }
    end
  end


  def destroy
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    if @config.config_value=='Daily'
      @absentee = Attendance.find params[:id]
    else
      @absentee = SubjectLeave.find params[:id]
      @tte_entry = TimetableEntry.find_by_subject_id_and_class_timing_id(@absentee.subject_id,@absentee.class_timing_id)
      sub=Subject.find @absentee.subject_id
    end
    @absentee.delete
    @student = Student.find(@absentee.student_id)
    respond_to do |format|
      format.js { render :action => 'update' }
    end
  end

  def only_privileged_employee_allowed
    @privilege = @current_user.privileges.map{|p| p.name}
    if @current_user.employee?
      @employee_subjects= @current_user.employee_record.subjects
      if @employee_subjects.empty? and !@privilege.include?("StudentAttendanceRegister")
        flash[:notice] = "#{t('flash_msg4')}"
        redirect_to :controller => 'user', :action => 'dashboard'
      else
        @allow_access = true
      end
    end
  end
end
