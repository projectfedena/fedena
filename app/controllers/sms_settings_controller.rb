class SmsSettingsController < ApplicationController
  filter_access_to :all
  
  def index
    @config = Configuration.available_modules
    unless @config.include?('SMS')
      redirect_to :controller=>"user" , :action=>"dashboard"
    else
      @application_sms_enabled = SmsSetting.find_by_settings_key("ApplicationEnabled")
      @student_admission_sms_enabled = SmsSetting.find_by_settings_key("StudentAdmissionEnabled")
      @exam_schedule_sms_enabled = SmsSetting.find_by_settings_key("ExamScheduleEnabled")
      @result_publish_sms_enabled = SmsSetting.find_by_settings_key("ResultPublishEnabled")
      @student_attendance_sms_enabled = SmsSetting.find_by_settings_key("AttendanceEnabled")
      @news_events_sms_enabled = SmsSetting.find_by_settings_key("NewsEventsEnabled")
      @parents_sms_enabled = SmsSetting.find_by_settings_key("ParentSmsEnabled")
      @students_sms_enabled = SmsSetting.find_by_settings_key("StudentSmsEnabled")
      if request.post?
        SmsSetting.update(@application_sms_enabled.id,:is_enabled=>params[:sms_settings][:application_enabled])
        redirect_to :action=>"index"
      end
    end
  end

  def update_general_sms_settings
    @student_admission_sms_enabled = SmsSetting.find_by_settings_key("StudentAdmissionEnabled")
    @exam_schedule_sms_enabled = SmsSetting.find_by_settings_key("ExamScheduleEnabled")
    @result_publish_sms_enabled = SmsSetting.find_by_settings_key("ResultPublishEnabled")
    @student_attendance_sms_enabled = SmsSetting.find_by_settings_key("AttendanceEnabled")
    @news_events_sms_enabled = SmsSetting.find_by_settings_key("NewsEventsEnabled")
    @parents_sms_enabled = SmsSetting.find_by_settings_key("ParentSmsEnabled")
    @students_sms_enabled = SmsSetting.find_by_settings_key("StudentSmsEnabled")
    SmsSetting.update(@student_admission_sms_enabled.id,:is_enabled=>params[:general_settings][:student_admission_enabled])
    SmsSetting.update(@exam_schedule_sms_enabled.id,:is_enabled=>params[:general_settings][:exam_schedule_enabled])
    SmsSetting.update(@result_publish_sms_enabled.id,:is_enabled=>params[:general_settings][:result_publish_enabled])
    SmsSetting.update(@student_attendance_sms_enabled.id,:is_enabled=>params[:general_settings][:student_attendance_enabled])
    SmsSetting.update(@news_events_sms_enabled.id,:is_enabled=>params[:general_settings][:news_events_enabled])
    SmsSetting.update(@parents_sms_enabled.id,:is_enabled=>params[:general_settings][:sms_parents_enabled])
    SmsSetting.update(@students_sms_enabled.id,:is_enabled=>params[:general_settings][:sms_students_enabled])
    redirect_to :action=>"index"
  end

end
