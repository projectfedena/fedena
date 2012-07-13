class CceGradeSetsController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def index
    @grade_sets=CceGradeSet.all
  end

  def new
    @grade_set=CceGradeSet.new
  end

  def create
    @grade_set=CceGradeSet.new(params[:cce_grade_set])
    if @grade_set.save
      flash[:notice]="CCE Gradeset created successfully."
      @grade_sets=CceGradeSet.all
    else
      @error=true
    end
  end

  def edit
    @grade_set=CceGradeSet.find(params[:id])
  end

  def update
    @grade_set=CceGradeSet.find(params[:id])
    @grade_set.name=params[:cce_grade_set][:name]
    if @grade_set.save
      flash[:notice]="CCE Gradeset updated successfully."
      @grade_sets=CceGradeSet.all
    else
      @error=true
    end
  end

  def show
    @grade_set=CceGradeSet.find(params[:id])
    @grades=@grade_set.cce_grades
  end

  def destroy
    @grade_set=CceGradeSet.find(params[:id])
    if @grade_set.observation_groups.empty?
      if @grade_set.destroy
        flash[:notice]="Grade set deleted."
      end
    else
      flash[:warn_notice]="Grade set #{@grade_set.name} is associated to some Co-Scholastic groups. Clear them before deleting."
    end
    redirect_to :action => "index"
  end

  def new_grade
    @grade_set=CceGradeSet.find(params[:id])
    @grade=CceGrade.new
    respond_to do |format|
      format.js { render :action => 'new_grade' }
    end
  end

  def create_grade
    if request.post?
      @grade=CceGrade.new(params[:cce_grade])
      @grade_set=@grade.cce_grade_set
      if @grade.save
        @grades=@grade_set.cce_grades
        flash[:notice]="Grade created successfully"
      else
        @error=true
      end
    end
  end

  def edit_grade
    @grade=CceGrade.find(params[:id])
    respond_to do |format|
      format.js { render :action => 'edit_grade' }
    end
  end

  def update_grade
    @grade=CceGrade.find(params[:id])
    @grade_set=@grade.cce_grade_set
    if @grade.update_attributes(params[:grade])
      @grades=@grade_set.cce_grades
      flash[:notice]="Grade updated successfully"
    else
      @error=true
    end
  end

  def destroy_grade
    @grade=CceGrade.find(params[:id])
    @grades=@grade.cce_grade_set.cce_grades
    if @grade.destroy
      flash[:notice]="Grade deleted."
    else
      flash[:notice]="Could not delete grade."
    end
    render(:update) do |page|
      page.replace_html 'flash-box', :text=>"<p class='flash-msg'>#{flash[:notice]}</p>" unless flash[:notice].nil?
      page.replace_html 'grades', :partial => 'grades', :object => @grades
    end
  end

  
end
