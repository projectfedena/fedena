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

class SmsSettingsController < ApplicationController
  filter_access_to :all
  
  def index
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
