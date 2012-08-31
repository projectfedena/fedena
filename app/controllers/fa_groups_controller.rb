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

class FaGroupsController < ApplicationController
  before_filter :login_required
  filter_access_to :all

  def index
    @fa_groups=FaGroup.active
  end

  def new
    @fa_group=FaGroup.new
    @exam_categories=CceExamCategory.all
    @grade_sets=CceGradeSet.all
  end

  def create
    @fa_group=FaGroup.new(params[:fa_group])
    if @fa_group.save
      @fa_groups=FaGroup.active
      flash[:notice]="FA Group created successfully."
    else
      @error=true
    end
  end

  def show
    @fa_group=FaGroup.find(params[:id])
    @fa_criterias=@fa_group.fa_criterias.active
  end

  def edit
    @fa_group=FaGroup.find(params[:id])
    @exam_categories=CceExamCategory.all
    @grade_sets=CceGradeSet.all
  end

  def update
    @fa_group=FaGroup.find(params[:id])
    @fa_group.attributes=params[:fa_group]
    if @fa_group.save
      @fa_groups=FaGroup.active
      flash[:notice]="FA Group updated successfully."
    else
      @error=true
    end
  end

  def destroy
    @fa_group=FaGroup.find(params[:id])
    if @fa_group.update_attribute(:is_deleted,true)
      flash[:notice]="FA Group deleted"
    else
      flash[:notice]="Unable to delete FA Group."
    end
    redirect_to :action => "index"
  end

  def assign_fa_groups
    @courses = Course.cce
    @subjects = []
  end

  def select_subjects
    @subjects = Subject.find(:all,:joins=>:batch, :conditions=>{:batches=>{:course_id=>params[:course_id]},:is_deleted=>false},:group=>:code)
    render :update do |page|
      page.replace_html 'subjects', :partial => 'subjects', :object => @subjects
    end
  end

  def select_fa_groups
    if request.post?
      @subject=Subject.find(params[:subject_id])
      @subject_fa_groups=@subject.fa_groups
      @fa_groups=FaGroup.active
      render(:update) do |page|
        page.replace_html 'flash-box',""
        page.replace_html 'select_fa_group',:partial=>"select_fa_groups"
      end
    end
  end

  def update_subject_fa_groups
    @subject=Subject.find(params[:id])
    subjects=Subject.find(:all,:joins=>:batch,:readonly=>false, :conditions=>{:code=>@subject.code, :is_deleted=>false,:batches=>{:course_id=>@subject.batch.course_id}})
    new_fa_groups = params[:subject][:fa_group_ids] if params[:subject]
    new_fa_groups ||= []
    fa_groups = FaGroup.find_all_by_id(new_fa_groups)
    a=s=nil
    Subject.transaction do
      subjects.each do |sub|
        s=sub
        s.fa_groups = fa_groups
        a=s.save
      end
    end
    
    #    flash[:notice] = (!a ? "not saved" : "saved" )
    if a
      flash[:notice] = "FA groups successfully assigned for the selected subject."
      render :js=>"window.location='/fa_groups/assign_fa_groups'"

    else
      @error_object=s
      @subject_fa_groups=@subject.fa_groups
      @fa_groups=FaGroup.active
      render(:update) do |page|
        page.replace_html 'error-div',:partial=>"layouts/errors"
        page.replace_html 'select_fa_group',:partial=>"select_fa_groups"
      end
    end
    #    redirect_to :action=>:assign_fa_groups
  end

  def new_fa_criteria
    @fa_group=FaGroup.find(params[:fa_group_id])
    @fa_criteria=@fa_group.fa_criterias.new
  end

  def create_fa_criteria
    @fa_criteria=FaCriteria.new(params[:fa_criteria])
    @fa_group=FaGroup.find(params[:fa_criteria][:fa_group_id])
    @fa_criteria.sort_order=@fa_group.fa_criterias.find(:last,:order=>"sort_order ASC").try(:sort_order).to_i+1 || 1
    if @fa_criteria.save
      @fa_criterias=@fa_group.fa_criterias.active
      flash[:notice]="FA Criteria created successfully"
    else
      @error=true
    end
  end

  def edit_fa_criteria
    @fa_criteria=FaCriteria.find(params[:id])
  end

  def update_fa_criteria
    @fa_criteria=FaCriteria.find(params[:id])
    @fa_criteria.attributes=params[:fa_criteria]
    if @fa_criteria.save
      @fa_criterias=@fa_criteria.fa_group.fa_criterias.active
      flash[:notice]="FA Criteria updated successfully"
    else
      @error=true
    end
  end

  def destroy_fa_criteria
    @fa_criteria=FaCriteria.find(params[:id])
    @fa_group=@fa_criteria.fa_group
    if @fa_criteria.update_attribute(:is_deleted,true)
      flash[:notice]="scholastic criteria deleted"
    else
      flash[:notice]="scholastic criteria cannot be deleted"
    end
    @fa_criterias=@fa_criteria.fa_group.fa_criterias.active
    render(:update) do |page|
      page.replace_html 'flash-box', :text=>"<p class='flash-msg'>#{flash[:notice]}</p>" unless flash[:notice].nil?
      page.replace_html 'fa_criterias', :partial => 'fa_criterias', :object => @fa_criterias
    end
  end

  def reorder
    if request.post?
      fa_criteria=FaCriteria.find(params[:id])
      fa_group=fa_criteria.fa_group
      swap=fa_group.fa_criterias.all(:order=>"sort_order ASC")
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
      @fa_criterias=fa_group.fa_criterias.active
      render(:update) do |page|
        page.replace_html 'fa_criterias', :partial => 'fa_criterias', :object => @fa_criterias
      end
    end
  end

end
