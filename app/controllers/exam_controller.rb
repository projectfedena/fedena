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
    @cce_exam_category_id = params[:exam_option][:cce_exam_category_id]
    @cce_exam_categories = CceExamCategory.all if @batch.cce_enabled?
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
      students = Student.find_all_by_batch_id(@batch.id,:select => [:user_id])
      available_user_ids = students.collect(&:user_id).compact
      Delayed::Job.enqueue(
        DelayedReminderJob.new( :sender_id  => current_user.id,
          :recipient_ids => available_user_ids,
          :subject=>"#{t('exam_scheduled')}",
          :body=>"#{@exam_group.name} #{t('has_been_scheduled')}  <br/> #{t('view_calendar')}")
      )
    end
    unless @exams.empty?
      ExamGroup.update(@exam_group.id,:is_published=>true) if params[:status] == "schedule"
      ExamGroup.update(@exam_group.id,:result_published=>true) if params[:status] == "result"
      sms_setting = SmsSetting.new()
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
              sms = Delayed::Job.enqueue(SmsManager.new(@message,recipients))
            end
          end
        end
        @sms_setting_notice = "#{t('exam_schedule_published')}" if params[:status] == "schedule"
        @sms_setting_notice = "#{t('result_has_been_published')}" if params[:status] == "result"
      else
        @sms_setting_notice = "#{t('exam_schedule_published_no_sms')}" if params[:status] == "schedule"
        @sms_setting_notice = "#{t('exam_result_published_no_sms')}" if params[:status] == "result"
      end
      if params[:status] == "result"
        students = Student.find_all_by_batch_id(@batch.id,:select => [:user_id])
        available_user_ids = students.collect(&:user_id).compact
        Delayed::Job.enqueue(
          DelayedReminderJob.new( :sender_id  => current_user.id,
            :recipient_ids => available_user_ids,
            :subject=>"#{t('result_published')}",
            :body=>"#{@exam_group.name} #{t('result_has_been_published')}  <br/>#{t('view_reports')}")
        )
      end
    else
      @no_exam_notice = "#{t('exam_scheduling_not_done')}"
    end
  end

  def grouping
    @batch = Batch.find(params[:id])
    @exam_groups = ExamGroup.find_all_by_batch_id(@batch.id)
    @exam_groups.reject!{|e| e.exam_type=="Grades"}
    if request.post?
      unless params[:exam_grouping].nil?
        unless params[:exam_grouping][:exam_group_ids].nil?
          weightages = params[:weightage]
          total = 0
          weightages.map{|w| total+=w.to_f}
          unless total=="100".to_f
            flash[:notice]="#{t('flash9')}"
            return
          else
            GroupedExam.delete_all(:batch_id=>@batch.id)
            exam_group_ids = params[:exam_grouping][:exam_group_ids]
            exam_group_ids.each_with_index do |e,i|
              GroupedExam.create(:exam_group_id=>e,:batch_id=>@batch.id,:weightage=>weightages[i])
            end
          end
        end
      else
        GroupedExam.delete_all(:batch_id=>@batch.id)
      end
      flash[:notice]="#{t('flash1')}"
    end
  end

  #REPORTS

  def list_batch_groups
    unless params[:course_id]==""
      @batch_groups = BatchGroup.find_all_by_course_id(params[:course_id])
      if @batch_groups.empty?
        render(:update) do|page|
          page.replace_html "batch_group_list", :text=>""
        end
      else
        render(:update) do|page|
          page.replace_html "batch_group_list", :partial=>"select_batch_group"
        end
      end
    else
      render(:update) do|page|
        page.replace_html "batch_group_list", :text=>""
      end
    end
  end

  def generate_previous_reports
    if request.post?
      unless params[:report][:batch_ids].blank?
        @batches = Batch.find_all_by_id(params[:report][:batch_ids])
        @batches.each do|batch|
          batch.job_type = "2"
          Delayed::Job.enqueue(batch)
        end
        flash[:notice]="Report generation in queue for batches #{@batches.collect(&:full_name).join(", ")}. <a href='/scheduled_jobs/Batch/2'>Click Here</a> to view the scheduled job."
      else
        flash[:notice]="#{t('flash11')}"
        return
      end
    end
  end

  def select_inactive_batches
    unless params[:course_id]==""
      @batches = Batch.find(:all, :conditions=>{:course_id=>params[:course_id],:is_active=>false,:is_deleted=>:false})
      if @batches.empty?
        render(:update) do|page|
          page.replace_html "select_inactive_batches", :text=>"<p class='flash-msg'>#{t('exam.flash12')}</p>"
        end
      else
        render(:update) do|page|
          page.replace_html "select_inactive_batches", :partial=>"inactive_batch_list"
        end
      end
    else
      render(:update) do|page|
        page.replace_html "select_inactive_batches", :text=>""
      end
    end
  end

  def generate_reports
    if request.post?
      unless !params[:report][:course_id].present? or params[:report][:course_id]==""
        @course = Course.find(params[:report][:course_id])
        if @course.has_batch_groups_with_active_batches
          unless !params[:report][:batch_group_id].present? or params[:report][:batch_group_id]==""
            @batch_group = BatchGroup.find(params[:report][:batch_group_id])
            @batches = @batch_group.batches
          end
        else
          @batches = @course.active_batches
        end
      end
      if @batches
        @batches.each do|batch|
          batch.job_type = "1"
          Delayed::Job.enqueue(batch)
        end
        flash[:notice]="Report generation in queue for batches #{@batches.collect(&:full_name).join(", ")}. <a href='/scheduled_jobs/Batch/1'>Click Here</a> to view the scheduled job."
      else
        flash[:notice]="#{t('flash11')}"
        return
      end
    end
  end

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
      @students=@batch.students.by_first_name
      @student = @students.first  unless @students.empty?
      if @student.nil?
        flash[:notice] = "#{t('flash_student_notice')}"
        redirect_to :action => 'exam_wise_report' and return
      end
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
      @student = Student.find_by_id(params[:student])
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
      if request.xhr?
        render(:update) do |page|
          page.replace_html   'exam_wise_report', :partial=>"exam_wise_report"
        end
      else
        @students = Student.find_all_by_id(params[:student])
      end
    end
  end

  def generated_report_pdf
    @config = Configuration.get_config_value('InstitutionName')
    @exam_group = ExamGroup.find(params[:exam_group])
    @batch = Batch.find(params[:batch])
    @students = @batch.students.by_first_name
    render :pdf => 'generated_report_pdf'
  end


  def consolidated_exam_report
    @exam_group = ExamGroup.find(params[:exam_group])
    @batch = @exam_group.batch
  end

  def consolidated_exam_report_pdf
    @exam_group = ExamGroup.find(params[:exam_group])
    @batch = @exam_group.batch
    render :pdf => 'consolidated_exam_report_pdf',
      :page_size=> 'A3'
    #        respond_to do |format|
    #            format.pdf { render :layout => false }
    #        end
  end

  def subject_rank
    @batches = Batch.active
    @subjects = []
  end

  def list_batch_subjects
    @subjects = Subject.find_all_by_batch_id(params[:batch_id],:conditions=>"is_deleted=false")
    render(:update) do |page|
      page.replace_html 'subject-select', :partial=>'rank_subject_select'
    end
  end

  def student_subject_rank
    unless params[:rank_report][:subject_id] == ""
      @subject = Subject.find(params[:rank_report][:subject_id])
      @batch = @subject.batch
      @students = @batch.students.by_first_name
      unless @subject.elective_group_id.nil?
        @students.reject!{|s| !StudentsSubject.exists?(:student_id=>s.id,:subject_id=>@subject.id)}
      end
      @exam_groups = ExamGroup.find(:all,:conditions=>{:batch_id=>@batch.id})
      @exam_groups.reject!{|e| e.exam_type=="Grades"}
    else
      flash[:notice] = "#{t('flash4')}"
      redirect_to :action=>'subject_rank'
    end
  end

  def student_subject_rank_pdf
    @subject = Subject.find(params[:subject_id])
    @batch = @subject.batch
    @students = @batch.students.by_first_name
    unless @subject.elective_group_id.nil?
      @students.reject!{|s| !StudentsSubject.exists?(:student_id=>s.id,:subject_id=>@subject.id)}
    end
    @exam_groups = ExamGroup.find(:all,:conditions=>{:batch_id=>@batch.id})
    @exam_groups.reject!{|e| e.exam_type=="Grades"}
    render :pdf => 'student_subject_rank_pdf'
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

  def student_batch_rank
    if params[:batch_rank].nil? or params[:batch_rank][:batch_id].empty?
      flash[:notice] = "#{t('select_a_batch_to_continue')}"
      redirect_to :action=>'batch_rank' and return
    else
      @batch = Batch.find(params[:batch_rank][:batch_id])
      @students = Student.find_all_by_batch_id(@batch.id)
      @grouped_exams = GroupedExam.find_all_by_batch_id(@batch.id)
      @ranked_students = @batch.find_batch_rank
    end
  end

  def student_batch_rank_pdf
    @batch = Batch.find(params[:batch_id])
    @students = Student.find_all_by_batch_id(@batch.id)
    @grouped_exams = GroupedExam.find_all_by_batch_id(@batch.id)
    @ranked_students = @batch.find_batch_rank
    render :pdf => "student_batch_rank_pdf"
  end
  
  def course_rank
  end

  def batch_groups
    unless params[:course_id]==""
      @course = Course.find(params[:course_id])
      if @course.has_batch_groups_with_active_batches
        @batch_groups = BatchGroup.find_all_by_course_id(params[:course_id])
        render(:update) do|page|
          page.replace_html "batch_group_list", :partial=>"batch_groups"
        end
      else
        render(:update) do|page|
          page.replace_html "batch_group_list", :text=>""
        end
      end
    else
      render(:update) do|page|
        page.replace_html "batch_group_list", :text=>""
      end
    end
  end

  def student_course_rank
    if params[:course_rank].nil? or params[:course_rank][:course_id]==""
      flash[:notice] = "#{t('flash13')}"
      redirect_to :action=>'course_rank' and return
    else
      @course = Course.find(params[:course_rank][:course_id])
      if @course.has_batch_groups_with_active_batches and (!params[:course_rank][:batch_group_id].present? or params[:course_rank][:batch_group_id]=="")
        flash[:notice] = "#{t('flash14')}"
        redirect_to :action=>'course_rank' and return
      else
        if @course.has_batch_groups_with_active_batches
          @batch_group = BatchGroup.find(params[:course_rank][:batch_group_id])
          @batches = @batch_group.batches
        else
          @batches = @course.active_batches
        end
        @students = Student.find_all_by_batch_id(@batches)
        @grouped_exams = GroupedExam.find_all_by_batch_id(@batches)
        @sort_order=""
        unless !params[:sort_order].present?
          @sort_order=params[:sort_order]
        end
        @ranked_students = @course.find_course_rank(@batches.collect(&:id),@sort_order).paginate(:page => params[:page], :per_page=>25)
      end
    end
  end

  def student_course_rank_pdf
    @course = Course.find(params[:course_id])
    if @course.has_batch_groups_with_active_batches
      @batch_group = BatchGroup.find(params[:batch_group_id])
      @batches = @batch_group.batches
    else
      @batches = @course.active_batches
    end
    @students = Student.find_all_by_batch_id(@batches)
    @grouped_exams = GroupedExam.find_all_by_batch_id(@batches)
    @sort_order=""
    unless !params[:sort_order].present?
      @sort_order=params[:sort_order]
    end
    @ranked_students = @course.find_course_rank(@batches.collect(&:id),@sort_order)
    render :pdf => "student_course_rank_pdf"
  end

  def student_school_rank
    @courses = Course.all(:conditions=>{:is_deleted=>false})
    @batches = Batch.all(:conditions=>{:course_id=>@courses,:is_deleted=>false,:is_active=>true})
    @students = Student.find_all_by_batch_id(@batches)
    @grouped_exams = GroupedExam.find_all_by_batch_id(@batches)
    @sort_order=""
    unless !params[:sort_order].present?
      @sort_order=params[:sort_order]
    end
    unless @courses.empty?
      @ranked_students = @courses.first.find_course_rank(@batches.collect(&:id),@sort_order).paginate(:page => params[:page], :per_page=>25)
    else
      @ranked_students=[]
    end
  end

  def student_school_rank_pdf
    @courses = Course.all(:conditions=>{:is_deleted=>false})
    @batches = Batch.all(:conditions=>{:course_id=>@courses,:is_deleted=>false,:is_active=>true})
    @students = Student.find_all_by_batch_id(@batches)
    @grouped_exams = GroupedExam.find_all_by_batch_id(@batches)
    @sort_order=""
    unless !params[:sort_order].present?
      @sort_order=params[:sort_order]
    end
    unless @courses.empty?
      @ranked_students = @courses.first.find_course_rank(@batches.collect(&:id),@sort_order)
    else
      @ranked_students=[]
    end
    render :pdf => "student_school_rank_pdf"
  end

  def student_attendance_rank
    if params[:attendance_rank].nil? or params[:attendance_rank][:batch_id].empty?
      flash[:notice] = "#{t('select_a_batch_to_continue')}"
      redirect_to :action=>'attendance_rank' and return
    else
      if params[:attendance_rank][:start_date].to_date > params[:attendance_rank][:end_date].to_date
        flash[:notice] = "#{t('flash15')}"
        redirect_to :action=>'attendance_rank' and return
      else
        @batch = Batch.find(params[:attendance_rank][:batch_id])
        @students = Student.find_all_by_batch_id(@batch.id)
        @start_date = params[:attendance_rank][:start_date].to_date
        @end_date = params[:attendance_rank][:end_date].to_date
        @ranked_students = @batch.find_attendance_rank(@start_date,@end_date)
      end
    end
  end

  def student_attendance_rank_pdf
    @batch = Batch.find(params[:batch_id])
    @students = Student.find_all_by_batch_id(@batch.id)
    @start_date = params[:start_date].to_date
    @end_date = params[:end_date].to_date
    @ranked_students = @batch.find_attendance_rank(@start_date,@end_date)
    render :pdf => "student_attendance_rank_pdf"
  end

  def ranking_level_report
  end

  def select_mode
    unless params[:mode].nil? or params[:mode]==""
      if params[:mode] == "batch"
        @batches = Batch.active
        render(:update) do|page|
          page.replace_html "course-batch", :partial=>"batch_select"
        end
      else
        @courses = Course.active
        render(:update) do|page|
          page.replace_html "course-batch", :partial=>"course_select"
        end
      end
    else
      render(:update) do|page|
        page.replace_html "course-batch", :text=>""
      end
    end
  end

  def select_batch_group
    unless params[:course_id].nil? or params[:course_id]==""
      @course = Course.find(params[:course_id])
      if @course.has_batch_groups_with_active_batches
        @batch_groups = BatchGroup.find_all_by_course_id(params[:course_id])
      end
      @ranking_levels = RankingLevel.find_all_by_course_id(params[:course_id])
      render(:update) do|page|
        page.replace_html "batch_groups", :partial=>"report_batch_groups"
      end
    else
      render(:update) do|page|
        page.replace_html "batch_groups", :text=>""
      end
    end
  end

  def select_type
    unless params[:report_type].nil? or params[:report_type]=="" or params[:report_type]=="overall"
      unless params[:batch_id].nil? or params[:batch_id]==""
        @batch = Batch.find(params[:batch_id])
        @subjects = Subject.find(:all,:conditions=>{:batch_id=>@batch.id,:is_deleted=>false})
        render(:update) do|page|
          page.replace_html "subject-select", :partial=>"subject_list"
        end
      else
        render(:update) do|page|
          page.replace_html "subject-select", :text=>""
        end
      end
    else
      render(:update) do|page|
        page.replace_html "subject-select", :text=>""
      end
    end
  end

  def student_ranking_level_report
    if params[:ranking_level_report].nil? or params[:ranking_level_report][:mode]==""
      flash[:notice]="#{t('flash16')}"
      redirect_to :action=>"ranking_level_report" and return
    else
      @mode = params[:ranking_level_report][:mode]
      if params[:ranking_level_report][:mode]=="batch"
        if params[:ranking_level_report][:batch_id]==""
          flash[:notice]="#{t('select_a_batch_to_continue')}"
          redirect_to :action=>"ranking_level_report" and return
        else
          @batch = Batch.find(params[:ranking_level_report][:batch_id])
          if params[:ranking_level_report].nil? or params[:ranking_level_report][:ranking_level_id]==""
            flash[:notice]="#{t('flash17')}"
            redirect_to :action=>"ranking_level_report" and return
          elsif params[:ranking_level_report][:report_type]==""
            flash[:notice]="#{t('flash18')}"
            redirect_to :action=>"ranking_level_report" and return
          else
            @ranking_level = RankingLevel.find(params[:ranking_level_report][:ranking_level_id])
            @report_type = params[:ranking_level_report][:report_type]
            if params[:ranking_level_report][:report_type]=="subject"
              if params[:ranking_level_report][:subject_id]==""
                flash[:notice]="#{t('flash4')}."
                redirect_to :action=>"ranking_level_report" and return
              else
                @students = @batch.students(:conditions=>{:is_active=>true,:is_deleted=>true})
                @subject = Subject.find(params[:ranking_level_report][:subject_id])
                @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:batch_id=>@batch.id,:subject_id=>@subject.id,:score_type=>"s"})
                unless @scores.empty?
                  if @batch.gpa_enabled?
                    @scores.reject!{|s| !((s.marks < @ranking_level.gpa if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.gpa if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.gpa if @ranking_level.marks_limit_type=="exact"))}
                  else
                    @scores.reject!{|s| !((s.marks < @ranking_level.marks if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.marks if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.marks if @ranking_level.marks_limit_type=="exact"))}
                  end
                else
                  flash[:notice]="#{t('flash19')}"
                  redirect_to :action=>"ranking_level_report" and return
                end
              end
            else
              @students = @batch.students(:conditions=>{:is_active=>true,:is_deleted=>true})
              unless @ranking_level.subject_count.nil?
                unless @ranking_level.full_course==true
                  @subjects = @batch.subjects
                  @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:batch_id=>@batch.id,:subject_id=>@subjects.collect(&:id),:score_type=>"s"})
                else
                  @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:score_type=>"s"})
                end
                unless @scores.empty?
                  if @batch.gpa_enabled?
                    @scores.reject!{|s| !((s.marks < @ranking_level.gpa if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.gpa if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.gpa if @ranking_level.marks_limit_type=="exact"))}
                  else
                    @scores.reject!{|s| !((s.marks < @ranking_level.marks if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.marks if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.marks if @ranking_level.marks_limit_type=="exact"))}
                  end
                else
                  flash[:notice]="#{t('flash19')}"
                  redirect_to :action=>"ranking_level_report" and return
                end
              else
                unless @ranking_level.full_course==true
                  @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:batch_id=>@batch.id,:score_type=>"c"})
                else
                  @scores = []
                  @students.each do|student|
                    total_student_score = 0
                    avg_student_score = 0
                    marks = GroupedExamReport.find_all_by_student_id_and_score_type(student.id,"c")
                    unless marks.empty?
                      marks.map{|m| total_student_score+=m.marks}
                      avg_student_score = total_student_score.to_f/marks.count.to_f
                      marks.first.marks = avg_student_score
                      @scores.push marks.first
                    end
                  end
                end
                unless @scores.empty?
                  if @batch.gpa_enabled?
                    @scores.reject!{|s| !((s.marks < @ranking_level.gpa if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.gpa if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.gpa if @ranking_level.marks_limit_type=="exact"))}
                  else
                    @scores.reject!{|s| !((s.marks < @ranking_level.marks if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.marks if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.marks if @ranking_level.marks_limit_type=="exact"))}
                  end
                else
                  flash[:notice]="#{t('flash19')}"
                  redirect_to :action=>"ranking_level_report" and return
                end
              end
            end
          end
        end
      else
        if params[:ranking_level_report][:course_id]==""
          flash[:notice]="#{t('flash13')}"
          redirect_to :action=>"ranking_level_report" and return
        else
          @course = Course.find(params[:ranking_level_report][:course_id])
          if @course.has_batch_groups_with_active_batches and (!params[:ranking_level_report][:batch_group_id].present? or params[:ranking_level_report][:batch_group_id]=="")
            flash[:notice]="#{t('flash14')}"
            redirect_to :action=>"ranking_level_report" and return
          elsif params[:ranking_level_report].nil? or params[:ranking_level_report][:ranking_level_id]==""
            flash[:notice]="#{t('flash17')}"
            redirect_to :action=>"ranking_level_report" and return
          else
            @ranking_level = RankingLevel.find(params[:ranking_level_report][:ranking_level_id])
            if @course.has_batch_groups_with_active_batches
              @batch_group = BatchGroup.find(params[:ranking_level_report][:batch_group_id])
              @batches = @batch_group.batches
            else
              @batches = @course.active_batches
            end
            @students = Student.find_all_by_batch_id(@batches.collect(&:id))
            unless @ranking_level.subject_count.nil?
              @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:score_type=>"s"})
            else
              unless @ranking_level.full_course==true
                @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:score_type=>"c"})
              else
                @scores = []
                @students.each do|student|
                  total_student_score = 0
                  avg_student_score = 0
                  marks = GroupedExamReport.find_all_by_student_id_and_score_type(student.id,"c")
                  unless marks.empty?
                    marks.map{|m| total_student_score+=m.marks}
                    avg_student_score = total_student_score.to_f/marks.count.to_f
                    marks.first.marks = avg_student_score
                    @scores.push marks.first
                  end
                end
              end
            end
            unless @scores.empty?
              if @ranking_level.marks_limit_type=="upper"
                @scores.reject!{|s| !(((s.marks < @ranking_level.gpa unless @ranking_level.gpa.nil?) if s.student.batch.gpa_enabled?) or (s.marks < @ranking_level.marks unless @ranking_level.marks.nil?))}
              elsif @ranking_level.marks_limit_type=="exact"
                @scores.reject!{|s| !(((s.marks == @ranking_level.gpa unless @ranking_level.gpa.nil?) if s.student.batch.gpa_enabled?) or (s.marks == @ranking_level.marks unless @ranking_level.marks.nil?))}
              else
                @scores.reject!{|s| !(((s.marks >= @ranking_level.gpa unless @ranking_level.gpa.nil?) if s.student.batch.gpa_enabled?) or (s.marks >= @ranking_level.marks unless @ranking_level.marks.nil?))}
              end
            else
              flash[:notice]="#{t('flash20')}"
              redirect_to :action=>"ranking_level_report" and return
            end
          end
        end
      end
    end
  end

  def student_ranking_level_report_pdf
    @ranking_level = RankingLevel.find(params[:ranking_level_id])
    @mode = params[:mode]
    if @mode=="batch"
      @batch = Batch.find(params[:batch_id])
      @report_type = params[:report_type]
      if @report_type=="subject"
        @students = @batch.students(:conditions=>{:is_active=>true,:is_deleted=>true})
        @subject = Subject.find(params[:subject_id])
        @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:batch_id=>@batch.id,:subject_id=>@subject.id,:score_type=>"s"})
        if @batch.gpa_enabled?
          @scores.reject!{|s| !((s.marks < @ranking_level.gpa if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.gpa if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.gpa if @ranking_level.marks_limit_type=="exact"))}
        else
          @scores.reject!{|s| !((s.marks < @ranking_level.marks if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.marks if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.marks if @ranking_level.marks_limit_type=="exact"))}
        end
      else
        @students = @batch.students(:conditions=>{:is_active=>true,:is_deleted=>true})
        unless @ranking_level.subject_count.nil?
          unless @ranking_level.full_course==true
            @subjects = @batch.subjects
            @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:batch_id=>@batch.id,:subject_id=>@subjects.collect(&:id),:score_type=>"s"})
          else
            @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:score_type=>"s"})
          end
          if @batch.gpa_enabled?
            @scores.reject!{|s| !((s.marks < @ranking_level.gpa if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.gpa if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.gpa if @ranking_level.marks_limit_type=="exact"))}
          else
            @scores.reject!{|s| !((s.marks < @ranking_level.marks if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.marks if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.marks if @ranking_level.marks_limit_type=="exact"))}
          end
        else
          unless @ranking_level.full_course==true
            @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:batch_id=>@batch.id,:score_type=>"c"})
          else
            @scores = []
            @students.each do|student|
              total_student_score = 0
              avg_student_score = 0
              marks = GroupedExamReport.find_all_by_student_id_and_score_type(student.id,"c")
              unless marks.empty?
                marks.map{|m| total_student_score+=m.marks}
                avg_student_score = total_student_score.to_f/marks.count.to_f
                marks.first.marks = avg_student_score
                @scores.push marks.first
              end
            end
          end
          if @batch.gpa_enabled?
            @scores.reject!{|s| !((s.marks < @ranking_level.gpa if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.gpa if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.gpa if @ranking_level.marks_limit_type=="exact"))}
          else
            @scores.reject!{|s| !((s.marks < @ranking_level.marks if @ranking_level.marks_limit_type=="upper") or (s.marks >= @ranking_level.marks if @ranking_level.marks_limit_type=="lower") or (s.marks == @ranking_level.marks if @ranking_level.marks_limit_type=="exact"))}
          end
        end
      end
    else
      @course = Course.find(params[:course_id])
      if @course.has_batch_groups_with_active_batches
        @batch_group = BatchGroup.find(params[:batch_group_id])
        @batches = @batch_group.batches
      else
        @batches = @course.active_batches
      end
      @students = Student.find_all_by_batch_id(@batches.collect(&:id))
      unless @ranking_level.subject_count.nil?
        @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:score_type=>"s"})
      else
        unless @ranking_level.full_course==true
          @scores = GroupedExamReport.find(:all,:conditions=>{:student_id=>@students.collect(&:id),:score_type=>"c"})
        else
          @scores = []
          @students.each do|student|
            total_student_score = 0
            avg_student_score = 0
            marks = GroupedExamReport.find_all_by_student_id_and_score_type(student.id,"c")
            unless marks.empty?
              marks.map{|m| total_student_score+=m.marks}
              avg_student_score = total_student_score.to_f/marks.count.to_f
              marks.first.marks = avg_student_score
              @scores.push marks.first
            end
          end
        end
      end
      if @ranking_level.marks_limit_type=="upper"
        @scores.reject!{|s| !(((s.marks < @ranking_level.gpa unless @ranking_level.gpa.nil?) if s.student.batch.gpa_enabled?) or (s.marks < @ranking_level.marks unless @ranking_level.marks.nil?))}
      elsif @ranking_level.marks_limit_type=="exact"
        @scores.reject!{|s| !(((s.marks == @ranking_level.gpa unless @ranking_level.gpa.nil?) if s.student.batch.gpa_enabled?) or (s.marks == @ranking_level.marks unless @ranking_level.marks.nil?))}
      else
        @scores.reject!{|s| !(((s.marks >= @ranking_level.gpa unless @ranking_level.gpa.nil?) if s.student.batch.gpa_enabled?) or (s.marks >= @ranking_level.marks unless @ranking_level.marks.nil?))}
      end
    end
    render :pdf=>"student_ranking_level_report_pdf"
  end

  def transcript
    @batches = Batch.active
  end

  def student_transcript
    if params[:transcript].nil? or params[:transcript][:student_id]==""
      flash[:notice] = "#{t('flash21')}"
      redirect_to :action=>"transcript" and return
    else
      @batch = Batch.find(params[:transcript][:batch_id])
      if params[:flag].present? and params[:flag]=="1"
        @students = Student.find_all_by_id(params[:student_id])
        if @students.empty?
          @students = ArchivedStudent.find_all_by_former_id(params[:student_id])
          @students.each do|student|
            student.id=student.former_id
          end
        end
        @flag = "1"
      else
        @students = @batch.students.by_first_name
      end
      unless @students.empty?
        unless !params[:student_id].present? or params[:student_id].nil?
          @student = Student.find_by_id(params[:student_id])
          if @student.nil?
            @student = ArchivedStudent.find_by_former_id(params[:student_id])
            @student.id = @student.former_id
          end
        else
          @student = @students.first
        end
        @grade_type = @batch.grading_type
        batch_ids = BatchStudent.find_all_by_student_id(@student.id).map{|b| b.batch_id}
        batch_ids << @batch.id
        @batches = Batch.find_all_by_id(batch_ids)
      else
        flash[:notice] = "No Students in this Batch."
        redirect_to :action=>"transcript" and return
      end
    end
  end

  def student_transcript_pdf
    @student = Student.find_by_id(params[:student_id])
    if @student.nil?
      @student = ArchivedStudent.find_by_former_id(params[:student_id])
      @student.id = @student.former_id
    end
    @batch = @student.batch
    @grade_type = @batch.grading_type
    batch_ids = BatchStudent.find_all_by_student_id(@student.id).map{|b| b.batch_id}
    batch_ids << @batch.id
    @batches = Batch.find_all_by_id(batch_ids)
    render :pdf=>"student_transcript_pdf"
  end

  def load_batch_students
    unless params[:id].nil? or params[:id]==""
      @batch = Batch.find(params[:id])
      @students = @batch.students.by_first_name
    else
      @students = []
    end
    render(:update) do|page|
      page.replace_html "student_selection", :partial=>"student_selection"
    end
  end

  def combined_report
    @batches = Batch.active
  end

  def load_levels
    unless params[:batch_id]==""
      @batch = Batch.find(params[:batch_id])
      @course = @batch.course
      @class_designations = @course.class_designations.all
      @ranking_levels = @course.ranking_levels.all.reject{|r| !(r.full_course==false)}
      render(:update) do|page|
        page.replace_html "levels", :partial=>"levels"
      end
    else
      render(:update) do|page|
        page.replace_html "levels", :text=>""
      end
    end
  end

  def student_combined_report
    if params[:combined_report][:batch_id]=="" or (params[:combined_report][:designation_ids].blank? and params[:combined_report][:level_ids].blank?)
      flash[:notice] = "#{t('flash22')}"
      redirect_to :action=>"combined_report" and return
    else
      @batch = Batch.find(params[:combined_report][:batch_id])
      @students = @batch.students
      unless params[:combined_report][:designation_ids].blank?
        @designations = ClassDesignation.find_all_by_id(params[:combined_report][:designation_ids])
      end
      unless params[:combined_report][:level_ids].blank?
        @levels = RankingLevel.find_all_by_id(params[:combined_report][:level_ids])
      end
    end
  end

  def student_combined_report_pdf
    @batch = Batch.find(params[:batch_id])
    @students = @batch.students
    unless params[:designations].blank?
      @designations = ClassDesignation.find_all_by_id(params[:designations])
    end
    unless params[:levels].blank?
      @levels = RankingLevel.find_all_by_id(params[:levels])
    end
    render :pdf=>"student_combined_report_pdf"#, :show_as_html=>true
  end



  def select_report_type
    unless params[:batch_id].nil? or params[:batch_id]==""
      @batch = Batch.find(params[:batch_id])
      @ranking_levels = RankingLevel.find_all_by_course_id(@batch.course_id)
      render(:update) do|page|
        page.replace_html "report_type_select", :partial=>"report_type_select"
      end
    else
      render(:update) do|page|
        page.replace_html "report_type_select", :text=>""
      end
    end
  end

  def generated_report3
    #student-subject-wise-report
    @student = Student.find(params[:student])
    @batch = @student.batch
    @subject = Subject.find(params[:subject])
    @exam_groups = ExamGroup.find(:all,:conditions=>{:batch_id=>@batch.id})
    @exam_groups.reject!{|e| e.result_published==false}
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
      @students=@batch.students.by_first_name
      @student = @students.first  unless @students.empty?
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
        @exam_groups.reject!{|e| e.result_published==false}
      end
      general_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>"elective_group_id IS NULL AND is_deleted=false")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
      @subjects.reject!{|s| s.no_exams==true}
      exams = Exam.find_all_by_exam_group_id(@exam_groups.collect(&:id))
      subject_ids = exams.collect(&:subject_id)
      @subjects.reject!{|sub| !(subject_ids.include?(sub.id))}
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
        @exam_groups.reject!{|e| e.result_published==false}
      end
      general_subjects = Subject.find_all_by_batch_id(@student.batch.id, :conditions=>"elective_group_id IS NULL AND is_deleted=false")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@student.batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
      @subjects.reject!{|s| s.no_exams==true}
      exams = Exam.find_all_by_exam_group_id(@exam_groups.collect(&:id))
      subject_ids = exams.collect(&:subject_id)
      @subjects.reject!{|sub| !(subject_ids.include?(sub.id))}
      if request.xhr?
        render(:update) do |page|
          page.replace_html   'grouped_exam_report', :partial=>"grouped_exam_report"
        end
      else
        @students = Student.find_all_by_id(params[:student])
      end
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
        @exam_groups.reject!{|e| e.result_published==false}
      end
      general_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>"elective_group_id IS NULL and is_deleted=false")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id,:conditions => {:is_deleted => false})
      end
      @subjects = general_subjects + elective_subjects
      @subjects.reject!{|s| s.no_exams==true}
      exams = Exam.find_all_by_exam_group_id(@exam_groups.collect(&:id))
      subject_ids = exams.collect(&:subject_id)
      @subjects.reject!{|sub| !(subject_ids.include?(sub.id))}
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
        @exam_groups.reject!{|e| e.result_published==false}
      end
      general_subjects = Subject.find_all_by_batch_id(@student.batch.id, :conditions=>"elective_group_id IS NULL")
      student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@student.batch.id}")
      elective_subjects = []
      student_electives.each do |elect|
        elective_subjects.push Subject.find(elect.subject_id)
      end
      @subjects = general_subjects + elective_subjects
      @subjects.reject!{|s| s.no_exams==true}
      exams = Exam.find_all_by_exam_group_id(@exam_groups.collect(&:id))
      subject_ids = exams.collect(&:subject_id)
      @subjects.reject!{|sub| !(subject_ids.include?(sub.id))}
    end
    render :pdf => 'generated_report4_pdf',
      :orientation => 'Landscape'
    #    respond_to do |format|
    #      format.pdf { render :layout => false }
    #    end

  end

  def combined_grouped_exam_report_pdf
    @type = params[:type]
    @batch = Batch.find(params[:batch])
    @students = @batch.students.by_first_name
    if @type == 'grouped'
      @grouped_exams = GroupedExam.find_all_by_batch_id(@batch.id)
      @exam_groups = []
      @grouped_exams.each do |x|
        @exam_groups.push ExamGroup.find(x.exam_group_id)
      end
    else
      @exam_groups = ExamGroup.find_all_by_batch_id(@batch.id)
      @exam_groups.reject!{|e| e.result_published==false}
    end
    render :pdf => 'combined_grouped_exam_report_pdf'
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
    general_subjects = Subject.find_all_by_batch_id(@batch.id, :conditions=>"elective_group_id IS NULL and is_deleted=false and no_exams=false")
    student_electives = StudentsSubject.find_all_by_student_id(@student.id,:conditions=>"batch_id = #{@batch.id}")
    elective_subjects = []
    student_electives.each do |elect|
      elective_subjects.push Subject.find(elect.subject_id)
    end
    @subjects = general_subjects + elective_subjects
  end

  def previous_batch_exams

  end

  def list_inactive_batches
    unless params[:course_id]==""
      @batches = Batch.find(:all, :conditions=>{:course_id=>params[:course_id],:is_active=>false,:is_deleted=>false})
      render(:update) do|page|
        page.replace_html "inactive_batches", :partial=>"inactive_batches"
      end
    else
      render(:update) do|page|
        page.replace_html "inactive_batches", :text=>""
      end
    end
  end

  def list_inactive_exam_groups
    unless params[:batch_id]==""
      @exam_groups = ExamGroup.find(:all, :conditions=>{:batch_id=>params[:batch_id]})
      @exam_groups.reject!{|e| !GroupedExam.exists?(:exam_group_id=>e.id,:batch_id=>params[:batch_id])}
      render(:update) do|page|
        page.replace_html "inactive_exam_groups", :partial=>"inactive_exam_groups"
      end
    else
      render(:update) do|page|
        page.replace_html "inactive_exam_groups", :text=>""
      end
    end
  end

  def previous_exam_marks
    unless params[:exam_goup_id]==""
      @exam_group = ExamGroup.find(params[:exam_group_id], :include => :exams)
      render(:update) do|page|
        page.replace_html "previous_exam_marks", :partial=>"previous_exam_marks"
      end
    else
      render(:update) do|page|
        page.replace_html "previous_exam_marks", :text=>""
      end
    end
  end

  def edit_previous_marks
    @employee_subjects=[]
    @employee_subjects= @current_user.employee_record.subjects.map { |n| n.id} if @current_user.employee?
    @exam = Exam.find params[:exam_id], :include => :exam_group
    @exam_group = @exam.exam_group
    @batch = @exam_group.batch
    unless @employee_subjects.include?(@exam.subject_id) or @current_user.admin? or @current_user.privileges.map{|p| p.name}.include?('ExaminationControl') or @current_user.privileges.map{|p| p.name}.include?('EnterResults')
      flash[:notice] = "#{t('flash_msg6')}"
      redirect_to :controller=>"user", :action=>"dashboard"
    end
    scores = ExamScore.find_all_by_exam_id(@exam.id)
    @students = []
    unless scores.empty?
      scores.each do|score|
        student = Student.find_by_id(score.student_id)
        @students.push [student.first_name,student.id,student] unless student.nil?
      end
    end
    @ordered_students = @students.sort
    @students=[]
    @ordered_students.each do|s|
      @students.push s[2]
    end
    @config = Configuration.get_config_value('ExamResultType') || 'Marks'

    @grades = @batch.grading_level_list
  end

  def update_previous_marks
    @exam = Exam.find(params[:exam_id])
    @error= false
    params[:exam].each_pair do |student_id, details|
      exam_score = ExamScore.find(:first, :conditions => {:exam_id => @exam.id, :student_id => student_id} )
      prev_score = ExamScore.find(:first, :conditions => {:exam_id => @exam.id, :student_id => student_id} )
      unless exam_score.nil?
        unless details[:marks].to_f == exam_score.marks.to_f
          if details[:marks].to_f <= @exam.maximum_marks.to_f
            if exam_score.update_attributes(details)
              PreviousExamScore.create(:student_id=>prev_score.student_id,:exam_id=>prev_score.exam_id,:marks=>prev_score.marks,:grading_level_id=>prev_score.grading_level_id,:remarks=>prev_score.remarks,:is_failed=>prev_score.is_failed)
            else
              flash[:warn_notice] = "#{t('flash8')}"
              @error = nil
            end
          else
            @error = true
          end
        end
      end
    end
    flash[:notice] = "#{t('flash6')}" if @error == true
    flash[:notice] = "#{t('flash7')}" if @error == false
    redirect_to :controller=>"exam", :action=>"edit_previous_marks", :exam_id=>@exam.id
  end

  def create_exam
    privilege = current_user.privileges.map{|p| p.name}
    if current_user.admin or privilege.include?("ExaminationControl") or privilege.include?("EnterResults")
      @course= Course.find(:all,:conditions => { :is_deleted => false }, :order => 'code asc')
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

