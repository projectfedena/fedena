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
  filter_access_to :all
  before_filter :only_assigned_employee_allowed, :except => 'index'
  before_filter :only_privileged_employee_allowed, :only => 'index'
  def index
    @batches = Batch.active
    @config = Configuration.find_by_config_key('StudentAttendanceType')
  end

  def list_subject
    @batch = Batch.find(params[:batch_id])
    @subjects = @batch.subjects
    if @current_user.employee? and @allow_access ==true and !@current_user.privileges.map{|m| m.name}.include?("StudentAttendanceRegister")
      @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
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
      @today = Date.today
    end
    start_date = @today.beginning_of_month
    end_date = @today.end_of_month
    if @config.config_value == 'Daily'
      @batch = Batch.find(params[:batch_id])
      @students = Student.find_all_by_batch_id(@batch.id)
      @dates = PeriodEntry.find_all_by_batch_id(@batch.id, :conditions =>{:month_date => start_date..end_date}, :order=>'month_date asc')
    else
      @sub =Subject.find params[:subject_id]
      @batch = @sub.batch_id
      unless @sub.elective_group_id.nil?
        elective_student_ids = StudentsSubject.find_all_by_subject_id(@sub.id).map { |x| x.student_id }
        @students = Student.find_all_by_batch_id(@batch, :conditions=>"FIND_IN_SET(id,\"#{elective_student_ids.split.join(',')}\")")
      else
        @students = Student.find_all_by_batch_id(@batch)
      end
      @dates = PeriodEntry.find_all_by_batch_id_and_subject_id(@batch,@sub.id,  :conditions =>{:month_date => start_date..end_date},:order=>'month_date ASC')
    end
    respond_to do |format|
      format.js { render :action => 'show' }
    end
  end

  def new
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    @absentee = Attendance.new
    @student = Student.find(params[:id2])
    @period_entry_id = params[:id]
    respond_to do |format|
      format.js { render :action => 'new' }
    end
  end

  def create
    @absentee = Attendance.new(params[:attendance])
    @student = Student.find(params[:attendance][:student_id])
    @period_entry = PeriodEntry.find(params[:attendance][:period_table_entry_id],:order=>'month_date asc')
    respond_to do |format|
      if @absentee.save
        sms_setting = SmsSetting.new()
        if sms_setting.application_sms_active and @student.is_sms_enabled and sms_setting.attendance_sms_active
          recipients = []
          message = "#{@student.first_name} #{@student.last_name} #{t('flash_msg7')} #{@period_entry.month_date}"
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
            sms = SmsManager.new(message,recipients)
            sms.send_sms
          end
        end
        @batch = @student.batch
        @students = Student.find_all_by_batch_id(@batch.id)
        unless params[:next].nil?
          @today = params[:next].to_date
        else
          @today = Date.today
        end
        start_date = @today.beginning_of_month
        end_date = @today.end_of_month
        @dates = PeriodEntry.find_all_by_batch_id(@batch.id, :conditions =>{:month_date => start_date..end_date},:order=>'month_date ASC')
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
  @absentee = Attendance.find params[:id]
  @student = Student.find(@absentee.student_id)
  respond_to do |format|
    format.html { }
    format.js { render :action => 'edit' }
  end
end

def update

  @absentee = Attendance.find params[:id]
  @student = Student.find(@absentee.student_id)
  @period_entry = PeriodEntry.find @absentee.period_table_entry_id

    if @absentee.update_attributes(params[:attendance])
      @batch = @student.batch
      @students = Student.find_all_by_batch_id(@batch.id)
      unless params[:next].nil?
        @today = params[:next].to_date
      else
        @today = Date.today
      end
      start_date = @today.beginning_of_month
      end_date = @today.end_of_month
      @dates = PeriodEntry.find_all_by_batch_id(@batch.id, :conditions =>{:month_date => start_date..end_date},:order=>'month_date ASC')
    else
      @error = true
  end
  respond_to do |format|
      format.js { render :action => 'update' }
    end
end


def destroy
  @absentee = Attendance.find params[:id]
  @absentee.delete
  @student = Student.find(@absentee.student_id)
  @period_entry = PeriodEntry.find @absentee.period_table_entry_id
  respond_to do |format|
    @batch = @student.batch
    @students = Student.find_all_by_batch_id(@batch.id)
    unless params[:next].nil?
      @today = params[:next].to_date
    else
      @today = Date.today
    end
    start_date = @today.beginning_of_month
    end_date = @today.end_of_month
    @dates = PeriodEntry.find_all_by_batch_id(@batch.id, :conditions =>{:month_date => start_date..end_date},:order=>'month_date ASC')
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
