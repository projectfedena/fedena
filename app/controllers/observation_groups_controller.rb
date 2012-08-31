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

class ObservationGroupsController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def index
    @obs_groups=ObservationGroup.active
  end

  def new
    @obs_group=ObservationGroup.new
    @grade_sets=CceGradeSet.all
    @observation_kinds=ObservationGroup::OBSERVATION_KINDS
  end

  def create
    @obs_group=ObservationGroup.new(params[:observation_group])
    if @obs_group.save
      flash[:notice]="Co-Scholastic Group Created Successfully."
      @obs_groups=ObservationGroup.active
    else
      @error=true
    end
  end

  def show
    @obs_group=ObservationGroup.find(params[:id])
    @observations=@obs_group.observations.active
  end

  def edit
    @obs_group=ObservationGroup.find(params[:id])
    @grade_sets=CceGradeSet.all
    @observation_kinds=ObservationGroup::OBSERVATION_KINDS
  end

  def update
    @obs_group=ObservationGroup.find(params[:id])
    @obs_group.attributes=params[:observation_group]
    if @obs_group.save
      flash[:notice]="Co-Scholastic Group Updated Successfully."
      @obs_groups=ObservationGroup.active
    else
      @error=true
    end
  end
  def destroy
    @category=ObservationGroup.find(params[:id])
    if @category.update_attribute(:is_deleted,true)
      flash[:notice]="Co-Scholastic Group Deleted."
    else
      flash[:notice]="Unable to delete Co-Scholastic Group"
    end
    redirect_to :action => "index"
  end

  def new_observation
    @obs_group=ObservationGroup.find(params[:id])
    @observation=Observation.new
  end

  def create_observation
    @observation=Observation.new(params[:observation])
    @obs_group=ObservationGroup.find(params[:observation][:observation_group_id])
    @observation.sort_order=@obs_group.observations.find(:last,:conditions=>{:is_active=>true},:order=>"sort_order ASC").try(:sort_order).to_i+1 || 1
    @observation.is_active=true
    if @observation.save
      @observations=@obs_group.observations.active
      flash[:notice]="Co-Scholastic Criteria Created Successfully."
    else
      @error=true
    end
  end

  def edit_observation
    @observation=Observation.find(params[:id])
    @obs_group=@observation.observation_group
  end

  def update_observation
    @observation=Observation.find(params[:id])
    @observation.attributes=(params[:observation])
    @obs_group=ObservationGroup.find(params[:observation][:observation_group_id])
    if @observation.save
      @observations=@obs_group.observations.active
      flash[:notice]="Co-Scholastic Criteria updated Successfully."
    else
      @error=true
    end
  end

  def assign_courses
    @courses=Course.cce
  end

  def select_observation_groups
    if request.post?
      @course=Course.find(params[:course_id])
      @course_observation_groups=@course.observation_groups
      @obs_groups=ObservationGroup.active
      render(:update) do |page|
        page.replace_html 'flash-box',""
        page.replace_html 'select_observation_group',:partial=>"select_observation_group"
      end
    end
  end

  def update_course_obs_groups
    @course=Course.find(params[:id])
    new_observation_groups = params[:course][:observation_group_ids] if params[:course]
    new_observation_groups ||= []
    @course.observation_groups = ObservationGroup.find_all_by_id(new_observation_groups)
    @course_observation_groups=@course.observation_groups
    @obs_groups=ObservationGroup.all
    flash[:notice] = "Co-Scholastic groups successfully assigned to the selected course."
    render :js=>"window.location='/observation_groups/assign_courses'"
  end

  def destroy_observation
    @observation=Observation.find(params[:id])
    @obs_group=@observation.observation_group
    if @observation.update_attribute(:is_active,false)
      flash[:notice]="Co-scholastic criteria deleted."
    else
      flash[:notice]="Co-Scholastic criteria could not be deleted"
    end
    @observations=@obs_group.observations.find(:all,:conditions=>{:is_active=>true},:order=>"sort_order ASC")
    render(:update) do |page|
      page.replace_html 'flash-box', :text=>"<p class='flash-msg'>#{flash[:notice]}</p>" unless flash[:notice].nil?
      page.replace_html 'observations', :partial => 'observations', :object => @observations
    end
  end

  def reorder
    if request.post?
      observation=Observation.find(params[:id])
      obs_group=observation.observation_group
      swap=obs_group.observations.find(:all,:conditions=>{:is_active=>true},:order=>"sort_order ASC")
      initial=params[:count].to_i
      src=swap[initial]
      if params[:direction]=='up'
        dest=swap[initial-1]
      elsif params[:direction]=='down'
        dest=swap[initial+1]
      end
      dest_id=dest.sort_order.to_i
      dest.update_attribute(:sort_order,src.sort_order.to_i)
      src.update_attribute(:sort_order,dest_id)
      @observations=obs_group.observations.active
      render(:update) do |page|
        page.replace_html 'observations', :partial => 'observations', :object => @observations
      end
    end
  end
end
