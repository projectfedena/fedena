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

class SmsController < ApplicationController
  filter_access_to :all
  
  def index
    @sms_setting = SmsSetting.new()
    @parents_sms_enabled = SmsSetting.find_by_settings_key("ParentSmsEnabled")
    @students_sms_enabled = SmsSetting.find_by_settings_key("StudentSmsEnabled")
    @employees_sms_enabled = SmsSetting.find_by_settings_key("EmployeeSmsEnabled")
  end

  def settings
    @application_sms_enabled = SmsSetting.find_by_settings_key("ApplicationEnabled")
    @student_admission_sms_enabled = SmsSetting.find_by_settings_key("StudentAdmissionEnabled")
    @exam_schedule_result_sms_enabled = SmsSetting.find_by_settings_key("ExamScheduleResultEnabled")
    @student_attendance_sms_enabled = SmsSetting.find_by_settings_key("AttendanceEnabled")
    @news_events_sms_enabled = SmsSetting.find_by_settings_key("NewsEventsEnabled")
    @parents_sms_enabled = SmsSetting.find_by_settings_key("ParentSmsEnabled")
    @students_sms_enabled = SmsSetting.find_by_settings_key("StudentSmsEnabled")
    @employees_sms_enabled = SmsSetting.find_by_settings_key("EmployeeSmsEnabled")
    if request.post?
      SmsSetting.update(@application_sms_enabled.id,:is_enabled=>params[:sms_settings][:application_enabled])
      redirect_to :action=>"settings"
    end
  end

  def update_general_sms_settings
    @student_admission_sms_enabled = SmsSetting.find_by_settings_key("StudentAdmissionEnabled")
    @exam_schedule_result_sms_enabled = SmsSetting.find_by_settings_key("ExamScheduleResultEnabled")
    @student_attendance_sms_enabled = SmsSetting.find_by_settings_key("AttendanceEnabled")
    @news_events_sms_enabled = SmsSetting.find_by_settings_key("NewsEventsEnabled")
    @parents_sms_enabled = SmsSetting.find_by_settings_key("ParentSmsEnabled")
    @students_sms_enabled = SmsSetting.find_by_settings_key("StudentSmsEnabled")
    @employees_sms_enabled = SmsSetting.find_by_settings_key("EmployeeSmsEnabled")
    SmsSetting.update(@student_admission_sms_enabled.id,:is_enabled=>params[:general_settings][:student_admission_enabled])
    SmsSetting.update(@exam_schedule_result_sms_enabled.id,:is_enabled=>params[:general_settings][:exam_schedule_result_enabled])
    SmsSetting.update(@student_attendance_sms_enabled.id,:is_enabled=>params[:general_settings][:student_attendance_enabled])
    SmsSetting.update(@news_events_sms_enabled.id,:is_enabled=>params[:general_settings][:news_events_enabled])
    SmsSetting.update(@parents_sms_enabled.id,:is_enabled=>params[:general_settings][:sms_parents_enabled])
    SmsSetting.update(@students_sms_enabled.id,:is_enabled=>params[:general_settings][:sms_students_enabled])
    SmsSetting.update(@employees_sms_enabled.id,:is_enabled=>params[:general_settings][:sms_employees_enabled])
    redirect_to :action=>"settings"
  end

  def students
    if request.post?
      unless params[:send_sms][:student_ids].nil?
        student_ids = params[:send_sms][:student_ids]
        sms_setting = SmsSetting.new()
        @recipients=[]
        student_ids.each do |s_id|
          student = Student.find(s_id)
          guardian = student.immediate_contact
          if student.is_sms_enabled
            if sms_setting.student_sms_active           
              @recipients.push student.phone2 unless (student.phone2.nil? or student.phone2 == "")
            end
            if sms_setting.parent_sms_active
              unless guardian.nil?
                @recipients.push guardian.mobile_phone unless (guardian.mobile_phone.nil? or guardian.mobile_phone == "")
              end
            end
          end
        end
        unless @recipients.empty?
          message = params[:send_sms][:message]
          sms = Delayed::Job.enqueue(SmsManager.new(message,@recipients))
          # raise @recipients.inspect
          render(:update) do |page|
            page.replace_html 'status-message',:text=>"<p class=\"flash-msg\">#{t('sms_sending_intiated')}</p>"
            page.visual_effect(:highlight, 'status-message')
          end
        end
      end
    end
  end
  
  def list_students
    batch = Batch.find(params[:batch_id])
    @students = Student.find_all_by_batch_id(batch.id,:conditions=>'is_sms_enabled=true')
  end

  def batches
    @batches = Batch.active
    if request.post?
      unless params[:send_sms][:batch_ids].nil?
        batch_ids = params[:send_sms][:batch_ids]
        sms_setting = SmsSetting.new()
        @recipients = []
        batch_ids.each do |b_id|
          batch = Batch.find(b_id)
          batch_students = batch.students
          batch_students.each do |student|
            if student.is_sms_enabled
              if sms_setting.student_sms_active
                @recipients.push student.phone2 unless (student.phone2.nil? or student.phone2 == "")
              end
              if sms_setting.parent_sms_active
                guardian = student.immediate_contact
                unless guardian.nil?
                  @recipients.push guardian.mobile_phone unless (guardian.mobile_phone.nil? or guardian.mobile_phone == "")
                end
              end
            end
          end
        end
        unless @recipients.empty?
          message = params[:send_sms][:message]
          sms = Delayed::Job.enqueue(SmsManager.new(message,@recipients))
          render(:update) do |page|
            page.replace_html 'status-message',:text=>"<p class=\"flash-msg\">#{t('sms_sending_intiated')}</p>"
            page.visual_effect(:highlight, 'status-message')
          end
        end
      end
    end
  end

  def sms_all
    batches = Batch.active
    sms_setting = SmsSetting.new()
    @recipients = []
    batches.each do |batch|
      batch_students = batch.students
      batch_students.each do |student|
        if student.is_sms_enabled
          if sms_setting.student_sms_active
            @recipients.push student.phone2 unless (student.phone2.nil? or student.phone2 == "")
          end
          if sms_setting.parent_sms_active
            guardian = student.immediate_contact
            unless guardian.nil?
              @recipients.push guardian.mobile_phone unless (guardian.mobile_phone.nil? or guardian.mobile_phone == "")
            end
          end
        end
      end
    end
    emp_departments = EmployeeDepartment.find(:all)
    emp_departments.each do |dept|
      dept_employees = dept.employees
      dept_employees.each do |employee|
        if sms_setting.employee_sms_active
          @recipients.push employee.mobile_phone unless (employee.mobile_phone.nil? or employee.mobile_phone == "")
        end
      end
    end
    unless @recipients.empty?
      message = params[:send_sms][:message]
      Delayed::Job.enqueue(SmsManager.new(message,@recipients))
      render(:update) do |page|
        page.replace_html 'status-message',:text=>"<p class=\"flash-msg\">#{t('sms_sending_intiated')}</p>"
        page.visual_effect(:highlight, 'status-message')
      end
    end

  end

  def employees
    if request.post?
      unless params[:send_sms][:employee_ids].nil?
        employee_ids = params[:send_sms][:employee_ids]
        sms_setting = SmsSetting.new()
        @recipients=[]
        employee_ids.each do |e_id|
          employee = Employee.find(e_id)
          if sms_setting.employee_sms_active
            @recipients.push employee.mobile_phone unless (employee.mobile_phone.nil? or employee.mobile_phone == "")
          end
        end
        unless @recipients.empty?
          message = params[:send_sms][:message]
          Delayed::Job.enqueue(SmsManager.new(message,@recipients))
          render(:update) do |page|
            page.replace_html 'status-message',:text=>"<p class=\"flash-msg\">#{t('sms_sending_intiated')}</p>"
            page.visual_effect(:highlight, 'status-message')
          end
        end
      end
    end
  end

  def list_employees
    dept = EmployeeDepartment.find(params[:dept_id])
    @employees = dept.employees
  end

  def departments
    @departments = EmployeeDepartment.find(:all)
    if request.post?
      unless params[:send_sms][:dept_ids].nil?
        dept_ids = params[:send_sms][:dept_ids]
        sms_setting = SmsSetting.new()
        @recipients = []
        dept_ids.each do |d_id|
          department = EmployeeDepartment.find(d_id)
          department_employees = department.employees
          department_employees.each do |employee|
            if sms_setting.employee_sms_active
              @recipients.push employee.mobile_phone unless (employee.mobile_phone.nil? or employee.mobile_phone == "")
            end
          end
        end
        unless @recipients.empty?
          message = params[:send_sms][:message]
          Delayed::Job.enqueue(SmsManager.new(message,@recipients))
          render(:update) do |page|
            page.replace_html 'status-message',:text=>"<p class=\"flash-msg\">#{t('sms_sending_intiated')}</p>"
            page.visual_effect(:highlight, 'status-message')
          end
        end
      end
    end
  end

  def show_sms_messages
    @sms_messages = SmsMessage.get_sms_messages(params[:page])
    @total_sms = Configuration.get_config_value("TotalSmsCount")
  end

  def show_sms_logs
    @sms_message = SmsMessage.find(params[:id])
    @sms_logs = @sms_message.get_sms_logs(params[:page])
  end
end
