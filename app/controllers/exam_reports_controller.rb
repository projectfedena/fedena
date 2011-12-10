class ExamReportsController < ApplicationController

  before_filter :login_required
  before_filter :protect_other_student_data
  before_filter :restrict_employees_from_exam
  before_filter :load_archived_exam_prerequsites, :only=>[:archived_batches_exam_report,:archived_batches_exam_report_pdf]
  before_filter :load_consolidated_exam_prerequsites,:only=>[:consolidated_exam_report,:consolidated_exam_report_pdf]
  filter_access_to :all

  def archived_exam_wise_report
    @batches = Batch.inactive
    @exam_groups = []
  end

  def archived_batches_exam_report
    
  end

  def archived_batches_exam_report_pdf
    render :pdf => 'generate_deleted_student_report_pdf'
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
        flash[:notice]="No student found in that exam group."
        redirect_to :controller=>"exam_reports", :action=>"archived_exam_wise_report"
      end
    else
      flash[:notice]="No student found in that exam group."
      redirect_to :controller=>"exam_reports", :action=>"archived_exam_wise_report"
    end
  end

  def load_consolidated_exam_prerequsites
    @exam_group = ExamGroup.find(params[:exam_group])
    @active_students = @exam_group.batch.students + @exam_group.batch.graduated_students
    @archvied_students = @exam_group.batch.archived_students
  end
end
