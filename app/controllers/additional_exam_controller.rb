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

class AdditionalExamController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def index
  end

  def update_exam_form
    @batch = Batch.find(params[:batch])
    @name = params[:exam_option][:name]
    @type = params[:exam_option][:exam_type]

    unless @name == ''
      @additional_exam_group = AdditionalExamGroup.new
      
      @normal_subjects = Subject.find_all_by_batch_id(@batch.id,:conditions=>"no_exams = false AND elective_group_id IS NULL AND is_deleted = false")
      @elective_subjects = []
      elective_subjects = Subject.find_all_by_batch_id(@batch.id,:conditions=>"no_exams = false AND elective_group_id IS NOT NULL AND is_deleted = false")
      elective_subjects.each do |e|
        is_assigned = StudentsSubject.find_all_by_subject_id(e.id)
        unless is_assigned.empty?
          @elective_subjects.push e
        end
      end
      @all_subjects = @normal_subjects+@elective_subjects
      @all_subjects.each { |subject| @additional_exam_group.additional_exams.build(:subject_id => subject.id) }

 

      @students_list = ""
      for student in params[:students_list]
        @students_list += student + ","
      end unless params[:students_list].nil?



      if @type == 'Marks' or @type == 'MarksAndGrades'
        render(:update) do |page|
          page.replace_html 'exam-form', :partial=>'exam_marks_form'
          page.replace_html 'flash', :text=>''
        end
      else
        render(:update) do |page|
          page.replace_html 'exam-form', :partial=>'exam_grade_form'
          page.replace_html 'flash', :text=>''
        end
      end

    else
      render(:update) do |page|
        page.replace_html 'flash', :text=>"<div class='errorExplanation'><p> #{t('exam_name')}can\'t be blank</p></div>"
      end
    end
  end

  def publish
    @additional_exam_group = AdditionalExamGroup.find(params[:id])
    @additional_exams = @additional_exam_group.additional_exams
    @batch =  @additional_exam_group.batch
    @sms_setting_notice = ""
    @no_exam_notice = ""
    if params[:status] == "schedule"
      students=@additional_exam_group.students
      students.each do |s|
        student_user = s.user
        unless student_user.nil?
          Reminder.create(:sender=> current_user.id,:recipient=>student_user.id,
            :subject=>"Additional Exam Scheduled",          :body=>"#{@additional_exam_group.name} #{t('has_been_scheduled')} <br/> #{t('view_calendar')}")
        end
      end
    end
    unless @additional_exams.empty?
      AdditionalExamGroup.update( @additional_exam_group.id,:is_published=>true) if params[:status] == "schedule"
      AdditionalExamGroup.update( @additional_exam_group.id,:result_published=>true) if params[:status] == "result"
      sms_setting = SmsSetting.new()
      @conf = Configuration.available_modules
      if @conf.include?('SMS')

      if sms_setting.application_sms_active and sms_setting.exam_result_schedule_sms_active
        students = @additional_exam_group.students
        students.each do |s|
          guardian = s.immediate_contact

          recipients = []
          if s.is_sms_enabled
            if sms_setting.student_sms_active
              recipients.push s.phone2 unless s.phone2.nil?
            end
            if sms_setting.parent_sms_active
              recipients.push guardian.mobile_phone unless guardian.mobile_phone.nil?
            end
            @message = "#{@additional_exam_group.name} #{t(' exam_timetable_published')}." if params[:status] == "schedule"
            @message = "#{@additional_exam_group.name} #{t('exam_result_published')}." if params[:status] == "result"
            unless recipients.empty?
              sms = SmsManager.new(@message,recipients)
              sms.send_sms
            end
          end
        end
      else
        @sms_setting_notice = "#{t('exam_schedule_published')}" if params[:status] == "schedule"
        @sms_setting_notice = "#{t('exam_result_published')}" if params[:status] == "result"
      end
    else
      @sms_setting_notice = "#{t('exam_schedule_published_no_sms')}" if params[:status] == "schedule"
      @sms_setting_notice = "#{t('exam_result_published_no_sms')}" if params[:status] == "result"
  end
  if params[:status] == "result"
    students = @additional_exam_group.students
    students.each do |s|
      student_user = s.user
      Reminder.create(:sender=> current_user.id,:recipient=>student_user.id,
        :subject=>"#{t('result_published')}",
        :body=>"#{ @additional_exam_group.name} #{t('result_has_been_published')} <br/> #{t('view_reports')}")
    end
  end
else
  @no_exam_notice = "#{t('exam_scheduling_not_done')}"
end
end

def create_additional_exam
@course= Course
end

def update_batch
@batch = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false})

render(:update) do |page|
  page.replace_html 'update_batch', :partial=>'update_batch'
end

end
#REPORTS

end

