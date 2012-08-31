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

class ExamReportsController < ApplicationController

  before_filter :login_required
  before_filter :protect_other_student_data
  before_filter :restrict_employees_from_exam
  #before_filter :load_archived_exam_prerequsites, :only=>[:archived_batches_exam_report,:archived_batches_exam_report_pdf]
  before_filter :load_consolidated_exam_prerequsites,:only=>[:consolidated_exam_report,:consolidated_exam_report_pdf]
  filter_access_to :all

  def archived_exam_wise_report
    @courses = Course.active
    @batches = []
  end

  def list_inactivated_batches
    unless params[:course_id]==""
      @course = Course.find(params[:course_id])
      @batches = Batch.find(:all,:conditions=>{:course_id=>@course.id,:is_active=>false,:is_deleted=>false})
    else
      @batches = []
    end
    render(:update) do|page|
      page.replace_html "inactive_batches", :partial=>"inactive_batches"
    end
  end

  def final_archived_report_type
    batch = Batch.find(params[:batch_id])
    @grouped_exams = GroupedExam.find_all_by_batch_id(batch.id)
    render(:update) do |page|
      page.replace_html 'archived_report_type',:partial=>'report_type'
    end
  end

  def archived_batches_exam_report
    if params[:student].nil?
      if params[:exam_report].nil? or params[:exam_report][:batch_id].empty?
        flash[:notice] = "#{t('select_a_batch_to_continue')}"
        redirect_to :action=>'archived_exam_wise_report' and return
      end
    else
      if !params[:type].present? or params[:type].nil?
        flash[:notice] = "#{t('invalid_parameters')}"
        redirect_to :action=>'archived_exam_wise_report' and return
      end
    end
    #grouped-exam-report-for-batch
    if params[:student].nil?
      @type = params[:type]
      @batch = Batch.find(params[:exam_report][:batch_id])
      batch_students = BatchStudent.find_all_by_batch_id(@batch.id)
      @students = []
      unless batch_students.empty?
        batch_students.each do|bs|
          st = Student.find_by_id(bs.student_id)
          if st.nil?
            st = ArchivedStudent.find_by_former_id(bs.student_id)
            unless st.nil?
              st.id=bs.student_id
            end
          end
          unless st.nil?
            @students.push [st.first_name, st.id, st]
          end
        end
      end
      archived_students = ArchivedStudent.find_all_by_batch_id(@batch.id)
      unless archived_students.empty?
        archived_students.each do|ast|
          ast.id = ast.former_id
          @students.push [ast.first_name, ast.id, ast]
        end
      end
      @sorted_students = @students.sort
      @students=[]
      @sorted_students.each do|s|
        @students.push s[2]
      end
      #@students=@batch.students.all(:order=>"first_name ASC")
      @student = @students.first  unless @students.empty?
      if @student.blank?
        flash[:notice] = "#{t('flash1')}"
        redirect_to :action=>'archived_exam_wise_report' and return
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
      @student = Student.find_by_id(params[:student])
      if @student.nil?
        @student = ArchivedStudent.find_by_former_id(params[:student])
        unless @student.nil?
          @student.id = @student.former_id
        end
      end
      @batch = Batch.find(params[:batch_id])
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
      general_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>"elective_group_id IS NULL AND is_deleted=false")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
      render(:update) do |page|
        page.replace_html   'grouped_exam_report', :partial=>"grouped_exam_report"
      end
    end

#    unless params[:exam_report][:batch_id]==""
#      @batch = Batch.find(params[:exam_report][:batch_id])
#      grouped_exams = GroupedExam.find_all_by_batch_id(@batch.id)
#      if grouped_exams.empty?
#        flash[:notice]="Select a Batch to continue." and return
#      else
#        @exam_groups = ExamGroup.find_all_by_id(grouped_exams.collect(&:exam_group_id))
#
#      end
#    else
#      flash[:notice]="Select a Batch to continue." and return
#    end
  end

  def archived_batches_exam_report_pdf
     #grouped-exam-report-for-batch
    if params[:student].nil?
      @type = params[:type]
      @batch = Batch.find(params[:exam_report][:batch_id])
      batch_students = BatchStudent.find_all_by_batch_id(@batch.id)
      @students = []
      unless batch_students.empty?
        batch_students.each do|bs|
          st = Student.find_by_id(bs.student_id)
          if st.nil?
            st = ArchivedStudent.find_by_former_id(bs.student_id)
            unless st.nil?
              st.id=bs.student_id
            end
          end
          unless st.nil?
            @students.push st
          end
        end
      end
      @student = @students.first
      if @type == 'grouped'
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
        elective_subjects.push Subject.find(elect.subject_id,:conditions => {:is_deleted => false})
      end
      @subjects = general_subjects + elective_subjects
    else
      @student = Student.find_by_id(params[:student])
      if @student.nil?
        @student = ArchivedStudent.find_by_former_id(params[:student])
        unless @student.nil?
          @student.id = @student.former_id
        end
      end
      @batch = Batch.find(params[:batch_id])
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
      general_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>"elective_group_id IS NULL")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
    end
    render :pdf => 'archived_batches_exam_report_pdf',
      :orientation => 'Landscape'
    #    respond_to do |format|
    #      format.pdf { render :layout => false }
    #    end


    #render :pdf => 'generate_deleted_student_report_pdf'
  end

  def consolidated_exam_report

  end

  def consolidated_exam_report_pdf

    render :pdf => 'consolidated_exam_report_pdf',
      :page_size=> 'A3'
  end

  

  private

  def load_archived_exam_prerequsites
    exam_group_id = params[:exam_report] ? params[:exam_report][:exam_group_id] : params[:exam_group_id] ? params[:exam_group_id] : ""
    batch_id = params[:exam_report] ? params[:exam_report][:batch_id] : params[:batch_id] ? params[:batch_id] : ""
    if exam_group_id and batch_id
      @batch = Batch.find(batch_id)
      @exam_group = ExamGroup.find(exam_group_id)
      active_students = @batch.students + @batch.graduated_students
      archived_students = @batch.archived_students
      @students = active_students + archived_students
      if params[:student]
        find_student = active_students.select{|s| s.id==params[:student].to_i}
        @student = find_student.first unless find_student.blank?
        if @student.blank?
          find_student = archived_students.select{|s| s.former_id==params[:student].to_i}
          @student = find_student.first unless  find_student.blank?
        end
      else
        @student = active_students.first
      end
      if @student
        general_subjects = Subject.find_all_by_batch_id(@student.batch_id, :conditions=>"elective_group_id IS NULL")
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
      else
        flash[:notice]="#{t('flash2')}"
        redirect_to :controller=>"exam_reports", :action=>"archived_exam_wise_report"
      end
    else
      flash[:notice]="#{t('flash2')}"
      redirect_to :controller=>"exam_reports", :action=>"archived_exam_wise_report"
    end
  end

  def load_consolidated_exam_prerequsites
    @exam_group = ExamGroup.find(params[:exam_group])
    @active_students = @exam_group.batch.students + @exam_group.batch.graduated_students
    @archvied_students = @exam_group.batch.archived_students
  end
end
