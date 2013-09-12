# Fedena
# Copyright 2011 Foradian Technologies Private Limited
#
# This product includes software developed at
# Project Fedena - http://www.projectfedena.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class ExamGroupsController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  before_filter :initial_queries
  before_filter :check_admin_privileges, :only => [:new]
  before_filter :protect_other_student_data
  before_filter :restrict_employees_from_exam
  before_filter :protect_other_batch_exams, :only => [:show, :index]
  before_filter :check_employee_privileges, :only => [:show, :index, :destroy]
  in_place_edit_with_validation_for :exam_group, :name
  in_place_edit_with_validation_for :exam, :maximum_marks
  in_place_edit_with_validation_for :exam, :minimum_marks
  in_place_edit_with_validation_for :exam, :weightage

  def index
    @sms_setting = SmsSetting.new
    @exam_groups = @batch.exam_groups
  end

  def new
    @cce_exam_categories = CceExamCategory.all if @batch.cce_enabled?
  end

  def create
    @exam_group = ExamGroup.new(params[:exam_group])
    @exam_group.batch_id = @batch.id
    @type  = @exam_group.exam_type
    @error = false

    if @type != 'Grades'
      params[:exam_group][:exams_attributes].each do |exam|
        if exam[1][:_delete].to_s == '0' and @error == false
          if exam[1][:maximum_marks].blank?
            @exam_group.errors.add_to_base("#{t('maxmarks_cant_be_blank')}")
            @error = true
          end
          if exam[1][:minimum_marks].blank?
            @exam_group.errors.add_to_base("#{t('minmarks_cant_be_blank')}")
            @error = true
          end
        end
      end
    end

    if @error == false and @exam_group.save
      flash[:notice] = "#{t('flash1')}"
      redirect_to batch_exam_groups_path(@batch)
    else
      @cce_exam_categories = CceExamCategory.all if @batch.cce_enabled?
      render 'new'
    end
  end

  def edit
    @exam_group = ExamGroup.find(params[:id])
    @cce_exam_categories = CceExamCategory.all if @batch.cce_enabled?
  end

  def update
    @exam_group = ExamGroup.find(params[:id])
    if @exam_group.update_attributes(params[:exam_group])
      flash[:notice] = "#{t('flash2')}"
      redirect_to [@batch, @exam_group]
    else
      @cce_exam_categories = CceExamCategory.all if @batch.cce_enabled?
      render 'edit'
    end
  end

  def destroy
    @exam_group = ExamGroup.find(params[:id], :include => :exams)
    flash[:notice] = "#{t('flash3')}" if @exam_group.destroy
    redirect_to batch_exam_groups_path(@batch)
  end

  def show
    @exam_group = ExamGroup.find(params[:id], :include => :exams)
  end

  private

  def initial_queries
    @batch  = Batch.find(params[:batch_id], :include => :course) unless params[:batch_id].nil?
    @course = @batch.course unless @batch.nil?
  end

  def check_employee_privileges
    if @current_user.employee?
      @user_privileges   = @current_user.privileges
      @employee_subjects = @current_user.employee_record.subject_ids
      if @employee_subjects.empty? and !@user_privileges.find_by_name('ExaminationControl') and !@user_privileges.find_by_name('EnterResults')
        flash[:notice] = "#{t('flash_msg4')}"
        redirect_to :controller => 'user', :action => 'dashboard'
      end
    end
  end

  def check_admin_privileges
    @user_privileges = @current_user.privileges
    if !@current_user.admin? and !@user_privileges.find_by_name('ExaminationControl') and !@user_privileges.find_by_name('EnterResults')
      flash[:notice] = "#{t('flash_msg4')}"
      redirect_to :controller => 'user', :action => 'dashboard'
    end
  end

  def protect_other_batch_exams
    @user_privileges = @current_user.privileges
    if !@current_user.admin? and !@user_privileges.find_by_name('ExaminationControl') and !@user_privileges.find_by_name('EnterResults')
      @user_subjects = @current_user.employee_record.subjects.all(:group => 'batch_id')
      @user_batches  = @user_subjects.map { |x| x.batch_id } unless @current_user.employee_record.blank? or @user_subjects.nil?

      unless @user_batches.include?(params[:batch_id].to_i)
        flash[:notice] = "#{t('flash_msg4')}"
        redirect_to :controller => 'user', :action => 'dashboard'
      end
    end
  end
end