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

class ExamGroupsController < ApplicationController
  before_filter :initial_queries
  before_filter :protect_other_student_data
  before_filter :restrict_employees_from_exam
  in_place_edit_for :exam_group, :name
  filter_access_to :all
  in_place_edit_for :exam, :maximum_marks
  in_place_edit_for :exam, :minimum_marks
  in_place_edit_for :exam, :weightage

  def index
    @exam_groups = @batch.exam_groups
    if @current_user.employee?
      @employee_subjects= @current_user.employee_record.subjects.map { |n| n.id}
      if @employee_subjects.empty? and !@current_user.privileges.map{|p| p.id}.include?(1) and !@current_user.privileges.map{|p| p.id}.include?(2)
        flash[:notice] = "Sorry, you are not allowed to access that page."
        redirect_to :controller => 'user', :action => 'dashboard'
      end
    end
  end

  def new

  end

  def create
    @exam_group = ExamGroup.new(params[:exam_group])
    @exam_group.batch_id = @batch.id
    if @exam_group.save
      flash[:notice] = 'Exam group created successfully.'
      redirect_to batch_exam_groups_path(@batch)
    else
      render 'new'
    end
  end

  def edit
    @exam_group = ExamGroup.find params[:id]
  end

  def update
    @exam_group = ExamGroup.find params[:id]
    if @exam_group.update_attributes(params[:exam_group])
      flash[:notice] = 'Updated exam group successfully.'
      redirect_to [@batch, @exam_group]
    else
      render 'edit'
    end
  end

  def destroy
    @exam_group = ExamGroup.find(params[:id], :include => :exams)
    if @current_user.employee?
      @employee_subjects= @current_user.employee_record.subjects.map { |n| n.id}
      if @employee_subjects.empty? and !@current_user.privileges.map{|p| p.id}.include?(1) and !@current_user.privileges.map{|p| p.id}.include?(2)
        flash[:notice] = "Sorry, you are not allowed to access that page."
        redirect_to :controller => 'user', :action => 'dashboard'
      end
    end
    @exam_group.destroy
    redirect_to batch_exam_groups_path(@batch)
  end

  def show
    @exam_group = ExamGroup.find(params[:id], :include => :exams)
    if @current_user.employee?
      @employee_subjects= @current_user.employee_record.subjects.map { |n| n.id}
      if @employee_subjects.empty? and !@current_user.privileges.map{|p| p.id}.include?(1) and !@current_user.privileges.map{|p| p.id}.include?(2)
        flash[:notice] = "Sorry, you are not allowed to access that page."
        redirect_to :controller => 'user', :action => 'dashboard'
      end
    end
  end

  private
  def initial_queries
    @batch = Batch.find params[:batch_id], :include => :course unless params[:batch_id].nil?
    @course = @batch.course unless @batch.nil?
  end

end