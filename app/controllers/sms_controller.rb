class SmsController < ApplicationController
  filter_access_to :all
  
  def index
    @config = Configuration.available_modules
    unless @config.include?('SMS')
      redirect_to :controller=>"user" , :action=>"dashboard"
    else
      @sms_setting = SmsSetting.new()
    end
  end

  def settings
    @config = Configuration.available_modules
    unless @config.include?('SMS')
      redirect_to :controller=>"user" , :action=>"dashboard"
    else
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
        student_ids.each do |s_id|
          @recipients=[]
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
          unless @recipients.empty?
            message = params[:send_sms][:message]
            sms = SmsManager.new(message,@recipients)
            sms.send_sms
          end
        end
      end
      render(:update) do |page|
        page.replace_html 'status-message',:text=>"<p class=\"flash-msg\"> SMS sent successfully selected students and their guardians</p>"
        page.visual_effect(:highlight, 'status-message')
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
        batch_ids.each do |b_id|
          @recipients = []
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
          unless @recipients.empty?
            message = params[:send_sms][:message]
            sms = SmsManager.new(message,@recipients)
            sms.send_sms
          end
        end
      end
      render(:update) do |page|
        page.replace_html 'status-message',:text=>"<p class=\"flash-msg\">SMS sent successfully to students(guardians) of selected course</p>"
        page.visual_effect(:highlight, 'status-message')
      end
    end
  end

  def sms_all
    batches = Batch.active
    sms_setting = SmsSetting.new()
    batches.each do |batch|
      @recipients = []
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
      unless @recipients.empty?
        message = params[:send_sms][:message]
        sms = SmsManager.new(message,@recipients)
        sms.send_sms
      end
    end
    emp_departments = EmployeeDepartment.find(:all)
    emp_departments.each do |dept|
      @recipients = []
      dept_employees = dept.employees
      dept_employees.each do |employee|
        if sms_setting.employee_sms_active
          @recipients.push employee.mobile_phone unless (employee.mobile_phone.nil? or employee.mobile_phone == "")
        end
      end
      unless @recipients.empty?
        message = params[:send_sms][:message]
        sms = SmsManager.new(message,@recipients)
        sms.send_sms
      end
    end
  end

  def employees
    if request.post?
      unless params[:send_sms][:employee_ids].nil?
        employee_ids = params[:send_sms][:employee_ids]
        sms_setting = SmsSetting.new()
        employee_ids.each do |e_id|
          @recipients=[]
          employee = Employee.find(e_id)
          if sms_setting.employee_sms_active
            @recipients.push employee.mobile_phone unless (employee.mobile_phone.nil? or employee.mobile_phone == "")
          end
          unless @recipients.empty?
            message = params[:send_sms][:message]
            sms = SmsManager.new(message,@recipients)
            sms.send_sms
          end
        end
      end
      render(:update) do |page|
        page.replace_html 'status-message',:text=>"<p class=\"flash-msg\">SMS sent successfully to selected employees</p>"
        page.visual_effect(:highlight, 'status-message')
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
        dept_ids.each do |d_id|
          @recipients = []
          department = EmployeeDepartment.find(d_id)
          department_employees = department.employees
          department_employees.each do |employee|
            if sms_setting.employee_sms_active
              @recipients.push employee.mobile_phone unless (employee.mobile_phone.nil? or employee.mobile_phone == "")
            end
          end
          unless @recipients.empty?
            message = params[:send_sms][:message]
            sms = SmsManager.new(message,@recipients)
            sms.send_sms
          end
        end
      end
      render(:update) do |page|
        page.replace_html 'status-message',:text=>"<p class=\"flash-msg\">SMS sent successfully to employees of selected department</p>"
        page.visual_effect(:highlight, 'status-message')
      end
    end
  end

end
