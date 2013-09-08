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
class ExamsController < ApplicationController
  before_filter :login_required
  before_filter :query_data
  before_filter :load_exam, :only => [:edit, :update, :show, :destroy]
  before_filter :protect_other_student_data
  before_filter :restrict_employees_from_exam, :except => [:edit, :destroy]
  before_filter :restrict_employees_from_exam_edit, :only => [:edit, :destroy]
  filter_access_to :all

  def new
    @exam = Exam.new
    load_subjects
    @subjects = @subjects.not_in_exam_group(@exam_group)
    if @subjects.blank?
      flash[:notice] = "#{t('flash_msg4')}"
      redirect_to [@batch, @exam_group]
    end
  end

  def create
    @exam = Exam.new(params[:exam])
    @exam.exam_group = @exam_group

    @error = false

    if @exam_group.exam_type != 'Grades'
      unless params[:exam][:maximum_marks].present?
        @exam.errors.add_to_base("#{t('maxmarks_cant_be_blank')}")
        @error = true
      end
      unless params[:exam][:minimum_marks].present?
        @exam.errors.add_to_base("#{t('minmarks_cant_be_blank')}")
        @error = true
      end
    end

    if !@error and @exam.save
      flash[:notice] = "#{t('flash_msg10')}"
      redirect_to [@batch, @exam_group]
    else
      load_subjects
      render 'new'
    end
  end

  def edit
    @subjects = @exam_group.batch.subjects
    check_for_employee_with_examination_control_access
  end

  def update
    if @exam.update_attributes(params[:exam])
      flash[:notice] = "#{t('flash1')}"
      redirect_to [@exam_group, @exam]
    else
      load_subjects
      render 'edit'
    end
  end

  def show
    @employee_subjects = []
    @employee_subjects = @current_user.employee_record.subject_ids if @current_user.employee?
    unless @employee_subjects.include?(@exam.subject_id) or @current_user.admin? or @current_user.privileges.map(&:name).include?('ExaminationControl') or @current_user.privileges.map(&:name).include?('EnterResults')
      flash[:notice] = "#{t('flash_msg6')}"
      redirect_to :controller => 'user', :action => 'dashboard'
    end

    exam_subject = Subject.find(@exam.subject_id)
    is_elective  = exam_subject.elective_group_id

    if is_elective
      assigned_students = StudentsSubject.find_all_by_subject_id(exam_subject.id)
      @students = []
      assigned_students.each do |s|
        student = Student.find_by_id(s.student_id)
        @students.push [student.first_name, student.id, student] if student
      end
      @ordered_students = @students.sort
      @students = []
      @ordered_students.each do|s|
        @students.push s[2]
      end
    else
      @students = @batch.students.by_first_name
    end

    @grades = @batch.grading_level_list
  end

  def destroy
    check_for_employee_with_examination_control_access

    if @exam.destroy
      batch_id = @exam.exam_group.batch_id
      batch_event = BatchEvent.find_by_event_id_and_batch_id(@exam.event_id,batch_id)
      event = Event.find_by_id(@exam.event_id)
      event.destroy
      batch_event.destroy
      flash[:notice] = "#{t('flash5')}"
    end
    redirect_to [@batch, @exam_group]
  end

  def save_scores
    @exam = Exam.find(params[:id])
    @error= false
    params[:exam].each_pair do |student_id, details|
      @exam_score = ExamScore.find(:first, :conditions => { :exam_id => @exam.id, :student_id => student_id })
      if @exam_score.nil?
        if details[:marks].to_f <= @exam.maximum_marks.to_f
          ExamScore.create do |score|
            score.exam_id          = @exam.id
            score.student_id       = student_id
            score.marks            = details[:marks]
            score.grading_level_id = details[:grading_level_id]
            score.remarks          = details[:remarks]
          end
        else
          @error = true
        end
      else
        if details[:marks].to_f <= @exam.maximum_marks.to_f
          if @exam_score.update_attributes(details)
          else
            flash[:warn_notice] = "#{t('flash4')}"
            @error = nil
          end
        else
          @error = true
        end
      end
    end

    flash[:warn_notice] = "#{t('flash2')}" if @error == true
    flash[:notice]      = "#{t('flash3')}" if @error == false

    redirect_to [@exam_group, @exam]
  end

  private

  def query_data
    @exam_group = ExamGroup.find(params[:exam_group_id], :include => :batch)
    @batch      = @exam_group.batch
    @course     = @batch.course
  end

  def load_exam
    @exam = Exam.find(params[:id], :include => :exam_group)
  end

  def load_subjects
    @subjects = @batch.subjects
    if @current_user.employee? and !@current_user.privileges.map(&:name).include?('ExaminationControl')
      @subjects = Subject.find(:all, :joins => %Q{
        INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id
        AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} })
    end
  end

  def check_for_employee_with_examination_control_access
    if @current_user.employee? and !@current_user.privileges.map(&:name).include?('ExaminationControl')
      @subjects = Subject.find(:all, :joins => "INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id}")
      unless @subjects.map(&:id).include?(@exam.subject_id)
        flash[:notice] = "#{t('flash_msg4')}"
        redirect_to [@batch, @exam_group]
      end
    end
  end

  def restrict_employees_from_exam_edit
    if @current_user.employee?
      if !@current_user.privileges.map{|p| p.name}.include?('ExaminationControl')
        flash[:notice] = "#{t('flash_msg4')}"
        redirect_to :back
      else
        @allow_for_exams = true
      end
    end
  end
end
