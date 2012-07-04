class CceReportsController < ApplicationController
  before_filter :login_required
  filter_access_to :all

  def index
    
  end
  
  def create_reports
    @courses = Course.active
    if request.post?
      unless params[:course][:batch_ids].blank?
        batches = Batch.find_all_by_id(params[:course][:batch_ids])
        batches.each do |batch|
          batch.generate_cce_reports
        end
        flash[:notice]="Reports generated for batches #{batches.collect(&:full_name).join(", ")}."
      else
        flash[:notice]="No batch selected"
      end
      redirect_to :action=>:index
    end
    
  end

  def student_wise_report
    @batches=Batch.cce
    if request.post?
      if params[:student].nil?
        @batch=Batch.find(params[:batch_id])
        @students=@batch.students
        render(:update) do |page|
          page.replace_html   'student_list', :partial=>"student_list",   :object=>@students
        end
      else
        @student = Student.find(params[:student])
        @batch=@student.batch
        fetch_report
        
        render(:update) do |page|
          page.replace_html   'report', :partial=>"student_report"
        end
      end
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
    @report=@student.individual_cce_report
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
