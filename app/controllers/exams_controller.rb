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

class ExamsController < ApplicationController
  before_filter :login_required
  before_filter :query_data
  before_filter :protect_other_student_data
  before_filter :restrict_employees_from_exam, :except=>[:edit, :destroy]
  before_filter :restrict_employees_from_exam_edit, :only=>[:edit, :destroy]
  filter_access_to :all

  def new
    @exam = Exam.new
    @subjects = @batch.subjects
    if @current_user.employee? and  !@current_user.privileges.map{|m| m.name}.include?("ExaminationControl")
      @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      if @subjects.blank?
        flash[:notice] = "#{t('flash_msg4')}"
        redirect_to [@batch, @exam_group]
      end
    end
  end

  def create
    @exam = Exam.new(params[:exam])
    @exam.exam_group_id = @exam_group.id
    if @exam.save
      flash[:notice] = "#{t('flash_msg10')}"
      redirect_to [@batch, @exam_group]
    else
      @subjects = @batch.subjects
      if @current_user.employee? and  !@current_user.privileges.map{|m| m.name}.include?("ExaminationControl")
        @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      end
      render 'new'
    end
  end

  def edit
    @exam = Exam.find params[:id], :include => :exam_group
    @subjects = @exam_group.batch.subjects
    if @current_user.employee?  and !@current_user.privileges.map{|m| m.name}.include?("ExaminationControl")
      @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      unless @subjects.map{|m| m.id}.include?(@exam.subject_id)
        flash[:notice] = "#{t('flash_msg4')}"
        redirect_to [@batch, @exam_group]
      end
    end
  end

  def update
    @exam = Exam.find params[:id], :include => :exam_group

    if @exam.update_attributes(params[:exam])
      flash[:notice] = "#{t('flash1')}"
      redirect_to [@exam_group, @exam]
    else
      @subjects = @batch.subjects
      if @current_user.employee? and  !@current_user.privileges.map{|m| m.name}.include?("ExaminationControl")
        @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      end
      render 'edit'
    end
  end

  def show
    @employee_subjects=[]
    @employee_subjects= @current_user.employee_record.subjects.map { |n| n.id} if @current_user.employee?
    @exam = Exam.find params[:id], :include => :exam_group
    unless @employee_subjects.include?(@exam.subject_id) or @current_user.admin? or @current_user.privileges.map{|p| p.name}.include?('ExaminationControl') or @current_user.privileges.map{|p| p.name}.include?('EnterResults')
      flash[:notice] = "#{t('flash_msg6')}"
      redirect_to :controller=>"user", :action=>"dashboard"
    end
    exam_subject = Subject.find(@exam.subject_id)
    is_elective = exam_subject.elective_group_id
    if is_elective == nil
      @students = @batch.students.by_first_name
    else
      assigned_students = StudentsSubject.find_all_by_subject_id(exam_subject.id)
      @students = []
      assigned_students.each do |s|
        student = Student.find_by_id(s.student_id)
        @students.push [student.first_name, student.id, student] unless student.nil?
      end
      @ordered_students = @students.sort
      @students=[]
      @ordered_students.each do|s|
        @students.push s[2]
      end
    end
    @config = Configuration.get_config_value('ExamResultType') || 'Marks'

    @grades = @batch.grading_level_list
  end

  def destroy
    @exam = Exam.find params[:id], :include => :exam_group
    if @current_user.employee?  and !@current_user.privileges.map{|m| m.name}.include?("ExaminationControl")
      @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      unless @subjects.map{|m| m.id}.include?(@exam.subject_id)
        flash[:notice] = "#{t('flash_msg4')}"
        redirect_to [@batch, @exam_group] and return
      end
    end
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
      @exam_score = ExamScore.find(:first, :conditions => {:exam_id => @exam.id, :student_id => student_id} )
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
    flash[:notice] = "#{t('flash3')}" if @error == false
    redirect_to [@exam_group, @exam]
  end

  private
  def query_data
    @exam_group = ExamGroup.find(params[:exam_group_id], :include => :batch)
    @batch = @exam_group.batch
    @course = @batch.course
  end

  def restrict_employees_from_exam_edit
    if @current_user.employee?
      if !@current_user.privileges.map{|p| p.name}.include?("ExaminationControl")
        flash[:notice] = "#{t('flash_msg4')}"
        redirect_to :back
      else
        @allow_for_exams = true
      end
    end
  end
end
