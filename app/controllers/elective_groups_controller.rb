class ElectiveGroupsController < ApplicationController
  before_filter :pre_load_objects

  def index
    @elective_groups = ElectiveGroup.for_batch(@batch.id, :include => :subjects)
  end

  def new
    @elective_group = @batch.elective_groups.build
  end

  def create
    @elective_group = ElectiveGroup.new(params[:elective_group])
    @elective_group.batch_id = @batch.id
    if @elective_group.save
      flash[:notice] = 'New elective group created.'
      redirect_to batch_elective_groups_path(@batch)
    else
       render :action=>'new'
    end
  end

  def edit
    @elective_group = ElectiveGroup.find(params[:id])
    render 'edit'
  end

  def update
    @elective_group = ElectiveGroup.find(params[:id])
    if @elective_group.update_attributes(params[:elective_group])
      flash[:notice] = 'Elective group updated.'
      #redirect_to [@batch, @elective_group]
      redirect_to batch_elective_groups_path(@batch)
    else
      render 'edit'
    end
  end

  def destroy
    @elective_group.inactivate
    flash[:notice] = 'Deleted elective group.'
    redirect_to batch_elective_groups_path(@batch)
  end

  def show
    @electives = Subject.find_all_by_batch_id_and_elective_group_id(@batch.id,@elective_group.id, :conditions=>["is_deleted = false"])
  end

  private
  def pre_load_objects
    @batch = Batch.find(params[:batch_id], :include => :course)
    @course = @batch.course
    @elective_group = ElectiveGroup.find(params[:id]) unless params[:id].nil?
  end
end
