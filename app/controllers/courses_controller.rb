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

class CoursesController < ApplicationController
  before_filter :login_required
  before_filter :find_course, :only => [:show, :edit, :update, :destroy]
  filter_access_to :all
  
  def index
    @courses = Course.active
  end

  def new
    @course = Course.new
    @grade_types=Course.grading_types_as_options
#    gpa = Configuration.find_by_config_key("GPA").config_value
#    if gpa == "1"
#      @grade_types << "GPA"
#    end
#    cwa = Configuration.find_by_config_key("CWA").config_value
#    if cwa == "1"
#      @grade_types << "CWA"
#    end
  end

  def manage_course
    @courses = Course.active
  end

  def manage_batches

  end

  def grouped_batches
    @course = Course.find(params[:id])
    @batch_groups = @course.batch_groups
    @batches = @course.active_batches.reject{|b| GroupedBatch.exists?(:batch_id=>b.id)}
    @batch_group = BatchGroup.new
  end

  def create_batch_group
    @batch_group = BatchGroup.new(params[:batch_group])
    @course = Course.find(params[:course_id])
    @batch_group.course_id = @course.id
    @error=false
    if params[:batch_ids].blank?
      @error=true
    end
    if @batch_group.valid? and @error==false
      @batch_group.save
      batches = params[:batch_ids]
      batches.each do|batch|
        GroupedBatch.create(:batch_group_id=>@batch_group.id,:batch_id=>batch)
      end
      @batch_group = BatchGroup.new
      @batch_groups = @course.batch_groups
      @batches = @course.active_batches.reject{|b| GroupedBatch.exists?(:batch_id=>b.id)}
      render(:update) do|page|
        page.replace_html "category-list", :partial=>"batch_groups"
        page.replace_html 'flash', :text=>'<p class="flash-msg"> Batch Group created successfully. </p>'
        page.replace_html 'errors', :partial=>"form_errors"
        page.replace_html 'class_form', :partial=>"batch_group_form"
      end
    else
      if params[:batch_ids].blank?
        @batch_group.errors.add_to_base "Atleast one batch must be selected."
      end
      render(:update) do|page|
        page.replace_html 'errors', :partial=>'form_errors'
        page.replace_html 'flash', :text=>""
      end
    end
  end

  def edit_batch_group
    @batch_group = BatchGroup.find(params[:id])
    @course = @batch_group.course
    @assigned_batches = @course.active_batches.reject{|b| (!GroupedBatch.exists?(:batch_id=>b.id,:batch_group_id=>@batch_group.id))}
    @batches = @course.active_batches.reject{|b| (GroupedBatch.exists?(:batch_id=>b.id))}
    @batches = @assigned_batches + @batches
    render(:update) do|page|
      page.replace_html "class_form", :partial=>"batch_group_edit_form"
      page.replace_html 'errors', :partial=>'form_errors'
      page.replace_html 'flash', :text=>""
    end
  end

  def update_batch_group
    @batch_group = BatchGroup.find(params[:id])
    @course = @batch_group.course
    unless params[:batch_ids].blank?
      if @batch_group.update_attributes(params[:batch_group])
        @batch_group.grouped_batches.map{|b| b.destroy}
        batches = params[:batch_ids]
        batches.each do|batch|
          GroupedBatch.create(:batch_group_id=>@batch_group.id,:batch_id=>batch)
        end
        @batch_group = BatchGroup.new
        @batch_groups = @course.batch_groups
        @batches = @course.active_batches.reject{|b| GroupedBatch.exists?(:batch_id=>b.id)}
        render(:update) do|page|
          page.replace_html "category-list", :partial=>"batch_groups"
          page.replace_html 'flash', :text=>'<p class="flash-msg"> Batch Group updated successfully. </p>'
          page.replace_html 'errors', :partial=>"form_errors"
          page.replace_html 'class_form', :partial=>"batch_group_form"
        end
      else
        render(:update) do|page|
          page.replace_html 'errors', :partial=>'form_errors'
          page.replace_html 'flash', :text=>""
        end
      end
    else
      @batch_group.errors.add_to_base("Atleat one Batch must be selected.")
      render(:update) do|page|
        page.replace_html 'errors', :partial=>'form_errors'
        page.replace_html 'flash', :text=>""
      end
    end
  end

  def delete_batch_group
    @batch_group = BatchGroup.find(params[:id])
    @course = @batch_group.course
    @batch_group.destroy
    @batch_group = BatchGroup.new
    @batch_groups = @course.batch_groups
    @batches = @course.active_batches.reject{|b| GroupedBatch.exists?(:batch_id=>b.id)}
    render(:update) do|page|
      page.replace_html "category-list", :partial=>"batch_groups"
      page.replace_html 'flash', :text=>'<p class="flash-msg"> Batch Group deleted successfully. </p>'
      page.replace_html 'errors', :partial=>"form_errors"
      page.replace_html 'class_form', :partial=>"batch_group_form"
    end
  end

  def update_batch
    @batch = Batch.find_all_by_course_id(params[:course_name], :conditions => { :is_deleted => false, :is_active => true })

    render(:update) do |page|
      page.replace_html 'update_batch', :partial=>'update_batch'
    end

  end

  def create
    @course = Course.new params[:course]
    if @course.save
      flash[:notice] = "#{t('flash1')}"
      redirect_to :action=>'manage_course'
    else
      @grade_types=Course.grading_types_as_options
#      gpa = Configuration.find_by_config_key("GPA").config_value
#      if gpa == "1"
#        @grade_types << "GPA"
#      end
#      cwa = Configuration.find_by_config_key("CWA").config_value
#      if cwa == "1"
#        @grade_types << "CWA"
#      end
      render 'new'
    end
  end

  def edit
    @grade_types=Course.grading_types_as_options
#    @grade_types=[]
#    gpa = Configuration.find_by_config_key("GPA").config_value
#    if gpa == "1"
#      @grade_types << "GPA"
#    end
#    cwa = Configuration.find_by_config_key("CWA").config_value
#    if cwa == "1"
#      @grade_types << "CWA"
#    end
  end

  def update
    if @course.update_attributes(params[:course])
#      if @course.cce_enabled
#        @course.batches.update_all(:grading_type=>nil)
#      end
      flash[:notice] = "#{t('flash2')}"
      redirect_to :action=>'manage_course'
    else
      @grade_types=Course.grading_types_as_options
      render 'edit'
    end
  end

  def destroy
    if @course.batches.active.empty?
      @course.inactivate
      flash[:notice]="#{t('flash3')}"
      redirect_to :action=>'manage_course'
    else
      flash[:warn_notice]="<p>#{t('courses.flash4')}</p>"
      redirect_to :action=>'manage_course'
    end
  
  end

  def show
    @batches = @course.batches.active
  end

  private
  def find_course
    @course = Course.find params[:id]
  end


end