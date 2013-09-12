# Fedena
# Copyright 2011 Foradian Technologies Private Limited
#
# This product includes software developed at
# Project Fedena - http://www.projectfedena.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class SmsSetting < ActiveRecord::Base

  def application_sms_active
    !!SmsSetting.find_by_settings_key_and_is_enabled("ApplicationEnabled", true)
  end

  def student_sms_active
    !!SmsSetting.find_by_settings_key_and_is_enabled("StudentSmsEnabled", true)
  end

  def student_admission_sms_active
    !!SmsSetting.find_by_settings_key_and_is_enabled("StudentAdmissionEnabled", true)
  end

  def parent_sms_active
    !!SmsSetting.find_by_settings_key_and_is_enabled("ParentSmsEnabled", true)
  end

  def employee_sms_active
    !!SmsSetting.find_by_settings_key_and_is_enabled("EmployeeSmsEnabled", true)
  end

  def attendance_sms_active
    !!SmsSetting.find_by_settings_key_and_is_enabled("AttendanceEnabled", true)
  end

  def event_news_sms_active
    !!SmsSetting.find_by_settings_key_and_is_enabled("NewsEventsEnabled", true)
  end

  def exam_result_schedule_sms_active
    !!SmsSetting.find_by_settings_key_and_is_enabled("ExamScheduleResultEnabled", true)
  end

  def self.get_sms_config
    if File.exists?("#{Rails.root}/config/sms_settings.yml")
      config = YAML.load_file(File.join(Rails.root,"config","sms_settings.yml"))
    end
    return config
  end

   def self.application_sms_status
    !!SmsSetting.find_by_settings_key_and_is_enabled("ApplicationEnabled", true)
  end
end
