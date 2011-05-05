class AdditionalExamGroupsController < ApplicationController
  before_filter :initial_queries
  filter_access_to :all
  in_place_edit_for :additional_exam_group, :name


  in_place_edit_for :additional_exam, :maximum_marks
  in_place_edit_for :additional_exam, :minimum_marks
  in_place_edit_for :additional_exam, :weightage


  def edit
    @additional_exam_group = AdditionalExamGroup.find params[:id]
  end

  def index
    @additional_exam_groups = @batch.additional_exam_groups
  end

  def new
    if @batch.is_active?
      @students = @batch.students
    else
      @students =    Student.find(:all,:joins =>'INNER JOIN `batch_students` ON `students`.id = `batch_students`.student_id AND batch_students.batch_id ='+ @batch.id.to_s )
    end
 
  end

  def show
    @additional_exam_group = AdditionalExamGroup.find(params[:id], :include => :additional_exams)
  end

  def create
    @students=@batch.students
    @additional_exam_group = AdditionalExamGroup.new(params[:additional_exam_group])
    @additional_exam_group.batch_id = @batch.id
    if @additional_exam_group.save

      flash[:notice] = "Additional Exam Group successfuly saved."
      redirect_to batch_additional_exam_groups_path(@batch)
    else
      render 'new'
    end
  end

  def update
    @additional_exam_group = AdditionalExamGroup.find params[:id]
    if @additional_exam_group.update_attributes(params[:additional_exam_group])
      flash[:notice] = 'Updated additional exam group successfully.'
      redirect_to [@batch, @additional_exam_group]
    else
      render 'edit'
    end
  end

  def destroy
      @exam_group = AdditionalExamGroup.find(params[:id], :include => :additional_exams)
      @exam_group.destroy
      redirect_to batch_additional_exam_groups_path(@batch)
    end

  private
  def initial_queries
    @batch = Batch.find params[:batch_id], :include => :course unless params[:batch_id].nil?
    @course = @batch.course unless @batch.nil?
  end

end
