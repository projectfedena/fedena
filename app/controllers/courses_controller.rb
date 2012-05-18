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
    @grade_types=[]
    gpa = Configuration.find_by_config_key("GPA").config_value
    if gpa == "1"
      @grade_types << "GPA"
    end
    cwa = Configuration.find_by_config_key("CWA").config_value
    if cwa == "1"
      @grade_types << "CWA"
    end
  end

  def manage_course
    @courses = Course.active
  end

  def manage_batches

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
      @grade_types=[]
    gpa = Configuration.find_by_config_key("GPA").config_value
    if gpa == "1"
      @grade_types << "GPA"
    end
    cwa = Configuration.find_by_config_key("CWA").config_value
    if cwa == "1"
      @grade_types << "CWA"
    end
      render 'new'
    end
  end

  def edit
  end

  def update
    if @course.update_attributes(params[:course])
      flash[:notice] = "#{t('flash2')}"
      redirect_to :action=>'manage_course'
    else
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