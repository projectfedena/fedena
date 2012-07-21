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

class ArchivedStudentController < ApplicationController
  filter_access_to :all

  def profile
    @current_user = current_user
    @archived_student = ArchivedStudent.find(params[:id])
    @additional_fields = StudentAdditionalField.all(:conditions=>"status = true")
  end

  def show
    @student = ArchivedStudent.find_by_admission_no(params[:id])
    send_data(@student.photo_data,
      :type => @student.photo_content_type,
      :filename => @student.photo_filename,
      :disposition => 'inline')
  end

  def guardians
    @archived_student = ArchivedStudent.find(params[:id])
    @parents = ArchivedGuardian.find(:all, :conditions=>"ward_id = #{@archived_student.id}")
  end


  def destroy
    archived_student = ArchivedStudent.find(params[:id])
    #        ArchivedStudent.destroy(params[:id])
    #        flash[:notice] = "All records have been deleted for student with admission no. #{archived_student.admission_no}."
    redirect_to :controller => 'user', :action => 'dashboard'
  end

  def reports
    @student= ArchivedStudent.find params[:id]
    @batch = @student.batch
    @grouped_exams = GroupedExam.find_all_by_batch_id(@batch.id)
    @normal_subjects = Subject.find_all_by_batch_id(@batch.id,:conditions=>"no_exams = false AND elective_group_id IS NULL AND is_deleted = false")
    @student_electives = StudentsSubject.find_all_by_student_id(@student.former_id,:conditions=>{:batch_id=>@batch.id})
    @elective_subjects = []
    @student_electives.each do |e|
      @elective_subjects.push Subject.find(e.subject_id)
    end
    @subjects = @normal_subjects+@elective_subjects
    @exam_groups = @batch.exam_groups
    @exam_groups.reject!{|e| e.result_published==false}
    @old_batches = @student.all_batches
  end

  def consolidated_exam_report
    @exam_group = ExamGroup.find(params[:exam_group])
  end

  def consolidated_exam_report_pdf
    @exam_group = ExamGroup.find(params[:exam_group])
    respond_to do |format|
      format.pdf { render :layout => false }
    end
  end

  def academic_report
    #academic-archived-report
    @student = ArchivedStudent.find(params[:student])
    @batch = Batch.find(params[:year])
    @type= params[:type]
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

  def student_report
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    @student = ArchivedStudent.find(params[:id])
    @batch = Batch.find(params[:year])
    @start_date = @batch.start_date.to_date
    if @student.created_at.to_date > @batch.end_date.to_date
      @end_date =  @batch.end_date.to_date
    else
      @end_date =  @student.created_at.to_date
    end
    unless @config.config_value == 'Daily'
      @academic_days=@batch.subject_hours(@start_date, @end_date, 0).values.flatten.compact.count
      @student_leaves = SubjectLeave.find(:all,  :conditions =>{:batch_id=>@batch.id,:student_id=>@student.former_id,:month_date => @start_date..@end_date})
      @leaves= @student_leaves.count
      @leaves||=0
      @attendance = (@academic_days - @leaves)
      @percent = (@attendance.to_f/@academic_days)*100 unless @academic_days == 0
    else
      @student_leaves = Attendance.find(:all,  :conditions =>{:student_id=>@student.former_id,:month_date => @start_date..@end_date})
      @academic_days=@batch.academic_days.select{|v| v<=@end_date}.count
      leaves_forenoon=Attendance.count(:all,:conditions=>{:student_id=>@student.former_id,:forenoon=>true,:afternoon=>false,:month_date => @start_date..@end_date})
      leaves_afternoon=Attendance.count(:all,:conditions=>{:student_id=>@student.former_id,:forenoon=>false,:afternoon=>true,:month_date => @start_date..@end_date})
      leaves_full=Attendance.count(:all,:conditions=>{:student_id=>@student.former_id,:forenoon=>true,:afternoon=>true,:month_date => @start_date..@end_date})
      @leaves=leaves_full.to_f+(0.5*(leaves_forenoon.to_f+leaves_afternoon.to_f))
      @attendance = (@academic_days - @leaves)
      @percent = (@attendance.to_f/@academic_days)*100 unless @academic_days == 0
    end
    #    @report = PeriodEntry.find_all_by_batch_id(@batch.id,  :conditions =>{:month_date => @start_date..@end_date})

  end


  def generated_report
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
        "/archived_student/graph_for_generated_report?batch=#{@student.batch.id}&examgroup=#{@exam_group.id}&student=#{@student.id}")
    else
      @exam_group = ExamGroup.find(params[:exam_group])
      @student = ArchivedStudent.find(params[:student])
      @student.id=@student.former_id
      @batch = @student.batch
      general_subjects = Subject.find_all_by_batch_id(@student.batch.id, :conditions=>"elective_group_id IS NULL")
      student_electives = StudentsSubject.find_all_by_student_id(@student.former_id,:conditions=>"batch_id = #{@student.batch.id}")
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
        "/archived_student/graph_for_generated_report?batch=#{@student.batch.id}&examgroup=#{@exam_group.id}&student=#{@student.id}")
    end
  end

  def generated_report_pdf
    @config = Configuration.get_config_value('InstitutionName')
    @exam_group = ExamGroup.find(params[:exam_group])
    @student = ArchivedStudent.find_by_former_id(params[:student])
    @student.id = @student.former_id
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
    render :pdf => 'generated_report_pdf'
          
    #    respond_to do |format|
    #      format.pdf { render :layout => false }
    #    end
  end

  def generated_report3
    #student-subject-wise-report
    @student = ArchivedStudent.find(params[:student])
    @student.id=@student.former_id
    @batch = @student.batch
    @subject = Subject.find(params[:subject])
    @exam_groups = ExamGroup.find(:all,:conditions=>{:batch_id=>@batch.id})
    @exam_groups.reject!{|e| e.result_published==false}
    @graph = open_flash_chart_object(770, 350,
      "/archived_student/graph_for_generated_report3?subject=#{@subject.id}&student=#{@student.id}")
  end

  def previous_years_marks_overview
    @type = params[:type]
    @student = ArchivedStudent.find(params[:student])
    @all_batches = @student.all_batches
    @graph = open_flash_chart_object(770, 350,
      "/archived_student/graph_for_previous_years_marks_overview?student=#{params[:student]}&graphtype=#{params[:graphtype]}")
  end


  def generated_report4
    #grouped-exam-report-for-batch
    unless params[:student].nil?
      @student = ArchivedStudent.find(params[:student])
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
        @exam_groups.reject!{|e| e.result_published==false}
      end
      general_subjects = Subject.find_all_by_batch_id(@student.batch.id, :conditions=>"elective_group_id IS NULL AND is_deleted=false")
      student_electives = StudentsSubject.find_all_by_student_id(@student.former_id,:conditions=>"batch_id = #{@student.batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
    end

  end

    
  def generated_report4_pdf

    #grouped-exam-report-for-batch
    unless params[:student].nil?
      @student = ArchivedStudent.find(params[:student])
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
        @exam_groups.reject!{|e| e.result_published==false}
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
    ##    respond_to do |format|
    ##      format.pdf { render :layout => false }
    ##    end

  end


  #GRAPHS

  def graph_for_generated_report
    student = ArchivedStudent.find_by_former_id(params[:student])
    student.id=student.former_id
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
    bargraph.text = "Student's marks"
    bargraph.values = data

    bargraph2 = BarFilled.new
    bargraph2.width = 1;
    bargraph2.colour = '#5E4725';
    bargraph2.dot_size = 5;
    bargraph2.text = "Class average"
    bargraph2.values = data2

    x_axis = XAxis.new
    x_axis.labels = x_labels

    y_axis = YAxis.new
    y_axis.set_range(0,100,20)

    title = Title.new(student.full_name)

    x_legend = XLegend.new("Subjects")
    x_legend.set_style('{font-size: 14px; color: #778877}')

    y_legend = YLegend.new("Marks")
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
    student = ArchivedStudent.find_by_former_id(params[:student])
    student.id = student.former_id
    subject = Subject.find params[:subject]
    exams = Exam.find_all_by_subject_id(subject.id, :order => 'start_time asc')
    exams.reject!{|e| e.exam_group.result_published==false}

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

    x_legend = XLegend.new("Examination name")
    x_legend.set_style('{font-size: 14px; color: #778877}')

    y_legend = YLegend.new("Marks")
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
    student = ArchivedStudent.find(params[:student])

    x_labels = []
    data = []

    student.all_batches.each do |b|
      x_labels << b.name
      exam = ArchivedExamScore.new()
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

    x_legend = XLegend.new("Academic year")
    x_legend.set_style('{font-size: 14px; color: #778877}')

    y_legend = YLegend.new("Total marks")
    y_legend.set_style('{font-size: 14px; color: #770077}')

    chart = OpenFlashChart.new
    chart.set_title(title)
    chart.y_axis = y_axis
    chart.x_axis = x_axis

    chart.add_element(line)

    render :text => chart.to_s
  end


end
