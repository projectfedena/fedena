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

class ExamController < ApplicationController
  before_filter :login_required
  before_filter :protect_other_student_data
  before_filter :restrict_employees_from_exam
  filter_access_to :all
  
  def index
  end

  def update_exam_form
    @batch = Batch.find(params[:batch])
    @name = params[:exam_option][:name]
    @type = params[:exam_option][:exam_type]
    unless @name == ''
      @exam_group = ExamGroup.new
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
      @all_subjects.each { |subject| @exam_group.exams.build(:subject_id => subject.id) }
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
        page.replace_html 'flash', :text=>"<div class='errorExplanation'><p>#{t('flash_msg9')}</p></div>"
      end
    end
  end

  def publish
    @exam_group = ExamGroup.find(params[:id])
    @exams = @exam_group.exams
    @batch = @exam_group.batch
    @sms_setting_notice = ""
    @no_exam_notice = ""
    if params[:status] == "schedule"
      students = @batch.students

      unless students.blank?
        students.each do |s|
          student_user = s.user
          Reminder.create(:sender=> current_user.id,:recipient=>student_user.id,
            :subject=>"#{t('exam_scheduled')}",
            :body=>"#{@exam_group.name} #{t('has_been_scheduled')}  <br/> #{t('view_calendar')}")
        end
      end
    end
    unless @exams.empty?
      ExamGroup.update(@exam_group.id,:is_published=>true) if params[:status] == "schedule"
      ExamGroup.update(@exam_group.id,:result_published=>true) if params[:status] == "result"
      sms_setting = SmsSetting.new()
      @conf = Configuration.available_modules
      if @conf.include?('SMS')
        if sms_setting.application_sms_active and sms_setting.exam_result_schedule_sms_active
          students = @batch.students
          students.each do |s|
            guardian = s.immediate_contact
            recipients = []
            if s.is_sms_enabled
              if sms_setting.student_sms_active
                recipients.push s.phone2 unless s.phone2.nil?
              end
              if sms_setting.parent_sms_active
                unless guardian.nil?
                  recipients.push guardian.mobile_phone unless guardian.mobile_phone.nil?
                end
              end
              @message = "#{@exam_group.name} #{t('exam_timetable_published')}" if params[:status] == "schedule"
              @message = "#{@exam_group.name} #{t('exam_result_published')}" if params[:status] == "result"
              unless recipients.empty?
                sms = SmsManager.new(@message,recipients)
                sms.send_sms
              end
            end
          end
          @sms_setting_notice = "#{t('exam_schedule_published')}" if params[:status] == "schedule"
          @sms_setting_notice = "#{t('result_has_been_published')}" if params[:status] == "result"
        else
          @sms_setting_notice = "#{t('exam_schedule_published_no_sms')}" if params[:status] == "schedule"
          @sms_setting_notice = "#{t('exam_result_published_no_sms')}" if params[:status] == "result"
        end
      else
        @sms_setting_notice = "#{t('exam_schedule_published')}" if params[:status] == "schedule"
        @sms_setting_notice = "#{t('result_has_been_published')}" if params[:status] == "result"
      end
      if params[:status] == "result"
        students = @batch.students
        students.each do |s|
          student_user = s.user
          Reminder.create(:sender=> current_user.id,:recipient=>student_user.id,
            :subject=>"#{t('result_published')}",
            :body=>"#{@exam_group.name} #{t('result_has_been_published')}  <br/>#{t('view_reports')}")
        end
      end
    else
      @no_exam_notice = "#{t('exam_scheduling_not_done')}"
    end
  end

  def grouping
    @batch = Batch.find(params[:id])
    @exam_groups = ExamGroup.find_all_by_batch_id(@batch.id)
    if request.post?
      unless params[:exam_grouping].nil?
        unless params[:exam_grouping][:exam_group_ids].nil?
          GroupedExam.delete_all(:batch_id=>@batch.id)
          exam_group_ids = params[:exam_grouping][:exam_group_ids]
          exam_group_ids.each do |e|
            GroupedExam.create(:exam_group_id=>e,:batch_id=>@batch.id)
          end
        end
      else
        GroupedExam.delete_all(:batch_id=>@batch.id)
      end
      flash[:notice]="#{t('flash1')}"
    end
  end

  #REPORTS

  def exam_wise_report
    @batches = Batch.active
    @exam_groups = []
  end

  def list_exam_types
    batch = Batch.find(params[:batch_id])
    @exam_groups = ExamGroup.find_all_by_batch_id(batch.id)
    render(:update) do |page|
      page.replace_html 'exam-group-select', :partial=>'exam_group_select'
    end
  end

  def generated_report
    if params[:student].nil?
      if params[:exam_report].nil? or params[:exam_report][:exam_group_id].empty?
        flash[:notice] = "#{t('flash2')}"
        redirect_to :action=>'exam_wise_report' and return
      end
    else
      if params[:exam_group].nil?
        flash[:notice] = "#{t('flash3')}"
        redirect_to :action=>'exam_wise_report' and return
      end
    end
    if params[:student].nil?
      @exam_group = ExamGroup.find(params[:exam_report][:exam_group_id])
      @batch = @exam_group.batch
      @student = @batch.students.first
      general_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>"elective_group_id IS NULL")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
      @exams = []
      @subjects.each do |sub|
        exam = Exam.find_by_exam_group_id_and_subject_id(@exam_group.id,sub.id)
        @exams.push exam unless exam.nil?
      end
      @graph = open_flash_chart_object(770, 350,
        "/exam/graph_for_generated_report?batch=#{@student.batch.id}&examgroup=#{@exam_group.id}&student=#{@student.id}")
    else
      @exam_group = ExamGroup.find(params[:exam_group])
      @student = Student.find(params[:student])
      @batch = @student.batch
      general_subjects = Subject.find_all_by_batch_id(@student.batch.id, :conditions=>"elective_group_id IS NULL")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@student.batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
      @exams = []
      @subjects.each do |sub|
        exam = Exam.find_by_exam_group_id_and_subject_id(@exam_group.id,sub.id)
        @exams.push exam unless exam.nil?
      end
      @graph = open_flash_chart_object(770, 350,
        "/exam/graph_for_generated_report?batch=#{@student.batch.id}&examgroup=#{@exam_group.id}&student=#{@student.id}")
    end
  end

  def generated_report_pdf
    @config = Configuration.get_config_value('InstitutionName')
    @exam_group = ExamGroup.find(params[:exam_group])
    @batch = Batch.find(params[:batch])
    @students = @batch.students
    render :pdf => 'generated_report_pdf'
  end


  def consolidated_exam_report
    @exam_group = ExamGroup.find(params[:exam_group])
  end

  def consolidated_exam_report_pdf
    @exam_group = ExamGroup.find(params[:exam_group])
    render :pdf => 'consolidated_exam_report_pdf',
      :page_size=> 'A3'
    #        respond_to do |format|
    #            format.pdf { render :layout => false }
    #        end
  end

  def subject_wise_report
    @batches = Batch.active
    @subjects = []
  end

  def list_subjects
    @subjects = Subject.find_all_by_batch_id(params[:batch_id],:conditions=>"is_deleted=false")
    render(:update) do |page|
      page.replace_html 'subject-select', :partial=>'subject_select'
    end
  end

  def generated_report2
    #subject-wise-report-for-batch
    unless params[:exam_report][:subject_id] == ""
      @subject = Subject.find(params[:exam_report][:subject_id])
      @batch = @subject.batch
      @students = @batch.students
      @exam_groups = ExamGroup.find(:all,:conditions=>{:batch_id=>@batch.id})
    else
      flash[:notice] = "#{t('flash4')}"
      redirect_to :action=>'subject_wise_report'
    end
  end
  def generated_report2_pdf
    #subject-wise-report-for-batch
    @subject = Subject.find(params[:subject_id])
    @batch = @subject.batch
    @students = @batch.students
    @exam_groups = ExamGroup.find(:all,:conditions=>{:batch_id=>@batch.id})
    render :pdf => 'generated_report_pdf'
          
    #        respond_to do |format|
    #            format.pdf { render :layout => false }
    #        end
  end

  def generated_report3
    #student-subject-wise-report
    @student = Student.find(params[:student])
    @batch = @student.batch
    @subject = Subject.find(params[:subject])
    @exam_groups = ExamGroup.find(:all,:conditions=>{:batch_id=>@batch.id})
    @graph = open_flash_chart_object(770, 350,
      "/exam/graph_for_generated_report3?subject=#{@subject.id}&student=#{@student.id}")
  end

  def final_report_type
    batch = Batch.find(params[:batch_id])
    @grouped_exams = GroupedExam.find_all_by_batch_id(batch.id)
    render(:update) do |page|
      page.replace_html 'report_type',:partial=>'report_type'
    end
  end

  def generated_report4
    if params[:student].nil?
      if params[:exam_report].nil? or params[:exam_report][:batch_id].empty?
        flash[:notice] = "#{t('select_a_batch_to_continue')}"
        redirect_to :action=>'grouped_exam_report' and return
      end
    else
      if params[:type].nil?
        flash[:notice] = "#{t('invalid_parameters')}"
        redirect_to :action=>'grouped_exam_report' and return
      end
    end
    #grouped-exam-report-for-batch
    if params[:student].nil?
      @type = params[:type]
      @batch = Batch.find(params[:exam_report][:batch_id])
      @student = @batch.students.first
      if @student.blank?
        flash[:notice] = "#{t('flash5')}"
        redirect_to :action=>'grouped_exam_report' and return
      end
      if @type == 'grouped'
        @grouped_exams = GroupedExam.find_all_by_batch_id(@batch.id)
        @exam_groups = []
        @grouped_exams.each do |x|
          @exam_groups.push ExamGroup.find(x.exam_group_id)
        end
      else
        @exam_groups = ExamGroup.find_all_by_batch_id(@batch.id)
      end
      general_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>"elective_group_id IS NULL AND is_deleted=false")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
    else
      @student = Student.find(params[:student])
      @batch = @student.batch
      @type  = params[:type]
      if params[:type] == 'grouped'
        @grouped_exams = GroupedExam.find_all_by_batch_id(@batch.id)
        @exam_groups = []
        @grouped_exams.each do |x|
          @exam_groups.push ExamGroup.find(x.exam_group_id)
        end
      else
        @exam_groups = ExamGroup.find_all_by_batch_id(@batch.id)
      end
      general_subjects = Subject.find_all_by_batch_id(@student.batch.id, :conditions=>"elective_group_id IS NULL AND is_deleted=false")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@student.batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
    end


  end
  def generated_report4_pdf

    #grouped-exam-report-for-batch
    if params[:student].nil?
      @type = params[:type]
      @batch = Batch.find(params[:exam_report][:batch_id])
      @student = @batch.students.first
      if @type == 'grouped'
        @grouped_exams = GroupedExam.find_all_by_batch_id(@batch.id)
        @exam_groups = []
        @grouped_exams.each do |x|
          @exam_groups.push ExamGroup.find(x.exam_group_id)
        end
      else
        @exam_groups = ExamGroup.find_all_by_batch_id(@batch.id)
      end
      general_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>"elective_group_id IS NULL")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
    else
      @student = Student.find(params[:student])
      @batch = @student.batch
      @type  = params[:type]
      if params[:type] == 'grouped'
        @grouped_exams = GroupedExam.find_all_by_batch_id(@batch.id)
        @exam_groups = []
        @grouped_exams.each do |x|
          @exam_groups.push ExamGroup.find(x.exam_group_id)
        end
      else
        @exam_groups = ExamGroup.find_all_by_batch_id(@batch.id)
      end
      general_subjects = Subject.find_all_by_batch_id(@student.batch.id, :conditions=>"elective_group_id IS NULL")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@student.batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
    end
    render :pdf => 'generated_report_pdf',
      :orientation => 'Landscape'
    #    respond_to do |format|
    #      format.pdf { render :layout => false }
    #    end

  end

  def previous_years_marks_overview
    @student = Student.find(params[:student])
    @all_batches = @student.all_batches
    @graph = open_flash_chart_object(770, 350,
      "/exam/graph_for_previous_years_marks_overview?student=#{params[:student]}&graphtype=#{params[:graphtype]}")
    respond_to do |format|
      format.pdf { render :layout => false }
      format.html
    end

  end
  
  def previous_years_marks_overview_pdf
    @student = Student.find(params[:student])
    @all_batches = @student.all_batches
    render :pdf => 'previous_years_marks_overview_pdf',
      :orientation => 'Landscape'
                        
    
  end

  def academic_report
    #academic-archived-report
    @student = Student.find(params[:student])
    @batch = Batch.find(params[:year])
    if params[:type] == 'grouped'
      @grouped_exams = GroupedExam.find_all_by_batch_id(@batch.id)
      @exam_groups = []
      @grouped_exams.each do |x|
        @exam_groups.push ExamGroup.find(x.exam_group_id)
      end
    else
      @exam_groups = ExamGroup.find_all_by_batch_id(@batch.id)
    end
    general_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>"elective_group_id IS NULL and is_deleted=false")
    student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@batch.id}")
    elective_subjects = []
    student_electives.each do |elect|
      elective_subjects.push Subject.find(elect.subject_id)
    end
    @subjects = general_subjects + elective_subjects
  end

  def create_exam
    if current_user.admin
      @course= Course.active
    elsif current_user.employee
      @course= current_user.employee_record.subjects.all(:group => 'batch_id').map{|x|x.batch.course}
    end
  end

  def update_batch_ex_result
    @batch = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false, :is_active => true })

    render(:update) do |page|
      page.replace_html 'update_batch', :partial=>'update_batch_ex_result'
    end
  end

  def update_batch
    @batch = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false, :is_active => true })

    render(:update) do |page|
      page.replace_html 'update_batch', :partial=>'update_batch'
    end

  end

  
  #GRAPHS

  def graph_for_generated_report
    student = Student.find(params[:student])
    examgroup = ExamGroup.find(params[:examgroup])
    batch = student.batch
    general_subjects = Subject.find_all_by_batch_id(batch.id, :conditions=>"elective_group_id IS NULL")
    student_electives = StudentsSubject.find_all_by_student_id(student.id,:conditions=>"batch_id = #{batch.id}")
    elective_subjects = []
    student_electives.each do |elect|
      elective_subjects.push Subject.find(elect.subject_id)
    end
    subjects = general_subjects + elective_subjects

    x_labels = []
    data = []
    data2 = []

    subjects.each do |s|
      exam = Exam.find_by_exam_group_id_and_subject_id(examgroup.id,s.id)
      res = ExamScore.find_by_exam_id_and_student_id(exam, student)
      unless res.nil?
        x_labels << s.code
        data << res.marks
        data2 << exam.class_average_marks
      end
    end

    bargraph = BarFilled.new()
    bargraph.width = 1;
    bargraph.colour = '#bb0000';
    bargraph.dot_size = 5;
    bargraph.text = "#{t('students_marks')}"
    bargraph.values = data

    bargraph2 = BarFilled.new
    bargraph2.width = 1;
    bargraph2.colour = '#5E4725';
    bargraph2.dot_size = 5;
    bargraph2.text = "#{t('class_average')}"
    bargraph2.values = data2

    x_axis = XAxis.new
    x_axis.labels = x_labels

    y_axis = YAxis.new
    y_axis.set_range(0,100,20)

    title = Title.new(student.full_name)

    x_legend = XLegend.new("#{t('subjects_text')}")
    x_legend.set_style('{font-size: 14px; color: #778877}')

    y_legend = YLegend.new("#{t('marks')}")
    y_legend.set_style('{font-size: 14px; color: #770077}')

    chart = OpenFlashChart.new
    chart.set_title(title)
    chart.y_axis = y_axis
    chart.x_axis = x_axis
    chart.y_legend = y_legend
    chart.x_legend = x_legend

    chart.add_element(bargraph)
    chart.add_element(bargraph2)

    render :text => chart.render
  end

  def graph_for_generated_report3
    student = Student.find params[:student]
    subject = Subject.find params[:subject]
    exams = Exam.find_all_by_subject_id(subject.id, :order => 'start_time asc')

    data = []
    x_labels = []

    exams.each do |e|
      exam_result = ExamScore.find_by_exam_id_and_student_id(e, student.id)
      unless exam_result.nil?
        data << exam_result.marks
        x_labels << XAxisLabel.new(exam_result.exam.exam_group.name, '#000000', 10, 0)
      end
    end

    x_axis = XAxis.new
    x_axis.labels = x_labels

    line = BarFilled.new

    line.width = 1
    line.colour = '#5E4725'
    line.dot_size = 5
    line.values = data

    y = YAxis.new
    y.set_range(0,100,20)

    title = Title.new(subject.name)

    x_legend = XLegend.new("#{t('examination_Name')}")
    x_legend.set_style('{font-size: 14px; color: #778877}')

    y_legend = YLegend.new("#{t('marks')}")
    y_legend.set_style('{font-size: 14px; color: #770077}')

    chart = OpenFlashChart.new
    chart.set_title(title)
    chart.set_x_legend(x_legend)
    chart.set_y_legend(y_legend)
    chart.y_axis = y
    chart.x_axis = x_axis

    chart.add_element(line)

    render :text => chart.to_s
  end

  def graph_for_previous_years_marks_overview
    student = Student.find(params[:student])

    x_labels = []
    data = []

    student.all_batches.each do |b|
      x_labels << b.name
      exam = ExamScore.new()
      data << exam.batch_wise_aggregate(student,b)
    end

    if params[:graphtype] == 'Line'
      line = Line.new
    else
      line = BarFilled.new
    end

    line.width = 1; line.colour = '#5E4725'; line.dot_size = 5; line.values = data

    x_axis = XAxis.new
    x_axis.labels = x_labels

    y_axis = YAxis.new
    y_axis.set_range(0,100,20)

    title = Title.new(student.full_name)

    x_legend = XLegend.new("#{t('academic_year')}")
    x_legend.set_style('{font-size: 14px; color: #778877}')

    y_legend = YLegend.new("#{t('total_marks')}")
    y_legend.set_style('{font-size: 14px; color: #770077}')

    chart = OpenFlashChart.new
    chart.set_title(title)
    chart.y_axis = y_axis
    chart.x_axis = x_axis

    chart.add_element(line)

    render :text => chart.to_s
  end

end

