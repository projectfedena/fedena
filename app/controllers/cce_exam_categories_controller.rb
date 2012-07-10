class CceExamCategoriesController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def index
    @categories=CceExamCategory.all
  end
  def new
    @category=CceExamCategory.new
  end
  def create
    @category=CceExamCategory.new(params[:cce_exam_category])
    if @category.save
      flash[:notice]="Exam Category created successfully."
      @categories=CceExamCategory.all
    else
      @error=true
    end
  end

  def edit
    @category=CceExamCategory.find(params[:id])
  end

  def update
    @category=CceExamCategory.find(params[:id])
    @category.name=params[:cce_exam_category][:name]
    @category.desc=params[:cce_exam_category][:desc]
    if @category.save
      flash[:notice]="Exam Category updated successfully."
      @categories=CceExamCategory.all
    else
      @error=true
    end
  end
  def destroy
    @category=CceExamCategory.find(params[:id])
    if @category.destroy
      flash[:notice]="Exam Category Deleted"
    else
      flash[:notice]="Exam category cannot be deleted"
    end
    redirect_to :action => "index"
  end
end
