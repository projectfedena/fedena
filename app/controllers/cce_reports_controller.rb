class CceReportsController < ApplicationController
  before_filter :login_required
  filter_access_to :all
    
  def index
    
  end
  
  def create_reports
    @courses = Course.cce
    if request.post?      
      unless params[:course][:batch_ids].blank?
        errors = []
        batches = Batch.find_all_by_id(params[:course][:batch_ids])
        batches.each do |batch|
          if batch.check_credit_points
            Delayed::Job.enqueue(batch)
            batch.delete_student_cce_report_cache
          else
            errors += ["Incomplete grading level credit points for #{batch.full_name}, report generation failed."]
          end
        end
        flash[:notice]="Report generation in queue for batches #{batches.collect(&:full_name).join(", ")}."
        flash[:error]=errors
      else
        flash[:notice]="No batch selected"
      end      
    end
    
  end

  def student_wise_report
    @batches=Batch.cce
    if request.post?      
      @batch=Batch.find(params[:batch_id])
      @students=@batch.students
      if @batch.user_is_authorized?(@current_user) or @current_user.has_subject_in_batch(@batch)
        render(:update) do |page|
          page.replace_html   'student_list', :partial=>"student_list",   :object=>@students          
          page.replace_html   'report', :text=>""
          page.replace_html   'hider', :text=>""
        end
      else
        flash[:notice]="You are not authorized to that batch"
        render :js=>"window.location='student_wise_report'"
        
      end
    end
  end

  def student_report
    @student = Student.find(params[:student])
    @batch=@student.batch
    fetch_report
    render(:update) do |page|
      page.replace_html   'report', :partial=>"student_report"
    end
  end

  def student_report_pdf
    @student=Student.find(params[:id])
    @batch=@student.batch
    fetch_report
    render :pdf => 'generated_report_pdf'
  end

  def student_transcript
    @student= (params[:type]=="former" ? ArchivedStudent.find(params[:id]) : Student.find(params[:id]))
    @type= params[:type] || "regular"
    @batch=(params[:batch_id].blank? ? @student.batch : Batch.find(params[:batch_id]))
    @batches=@student.all_batches.reverse unless request.xhr?
    @student.batch_in_context = @batch
    fetch_report
    if request.xhr?
      render(:update) do |page|
        page.replace_html   'report', :partial=>"student_report"
      end
    end
  end

  private

  def fetch_report
    @report=@student.individual_cce_report_cached
    @subjects=@student.all_subjects
    @exam_groups=ExamGroup.find_all_by_id(@report.exam_group_ids, :include=>:cce_exam_category)
    coscholastic=@report.coscholastic
    @observation_group_ids=coscholastic.collect(&:observation_group_id)
    @observation_groups=ObservationGroup.find(@observation_group_ids).collect(&:name)
    @co_hash=Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
    @obs_groups=@batch.observation_groups.to_a
    @og=@obs_groups.group_by(&:observation_kind)
    @co_hashi = {}
    @og.each do |kind, ogs|
      @co_hashi[kind]=[]
      coscholastic.each{|cs| @co_hashi[kind] << cs if ogs.collect(&:id).include? cs.observation_group_id}
    end       
  end
  
end
