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

class AdditionalExamsController < ApplicationController
  before_filter :login_required
  before_filter :query_data
  filter_access_to :all

  def show
    @additional_exam = AdditionalExam.find params[:id], :include => :additional_exam_group
    additional_exam_subject = Subject.find(@additional_exam.subject_id)

    @students = @additional_exam.additional_exam_group.students
    unless  additional_exam_subject.elective_group_id.nil?
      assigned_students_subject = StudentsSubject.find_all_by_subject_id(additional_exam_subject.id)
      assigned_students=       assigned_students_subject .map{|s| s.student}
      assigned_students_with_exam=assigned_students&@students
      @students= assigned_students_with_exam
    end
    @config = Configuration.get_config_value('ExamResultType') || 'Marks'

    @grades = @batch.grading_level_list
  end

  def edit
    @additional_exam = AdditionalExam.find params[:id], :include => :additional_exam_group
    @subjects = @additional_exam_group.batch.subjects
  end

  def new
    @additional_exam = AdditionalExam.new
    @subjects = @batch.subjects
  end

  def save_additional_scores
    @additional_exam = AdditionalExam.find(params[:id])
    @additional_exam_group = @additional_exam.additional_exam_group
    
    params[:additional_exam].each_pair do |student_id, details|
      @additional_exam_score = AdditionalExamScore.find(:first, :conditions => {:additional_exam_id => @additional_exam.id, :student_id => student_id} )
      if @additional_exam_score.nil?

        AdditionalExamScore.create do |score|
          score.additional_exam_id          = @additional_exam.id
          score.student_id       = student_id
          score.marks            = details[:marks]
          score.grading_level_id = details[:grading_level_id]
          score.remarks          = details[:remarks]
        end
      else
        @additional_exam_score.update_attributes(details)
      end
    end
    flash[:notice] = "#{t('flash1')}"
    redirect_to [@additional_exam_group, @additional_exam]
  end

  def create
    @additional_exam = @additional_exam_group.additional_exams.build(params[:additional_exam])
    if @additional_exam.save
      flash[:notice] = "#{t('flash_msg10')}"
      redirect_to [@batch, @additional_exam_group]
    else
      @subjects = @batch.subjects
      render 'new'
    end
  end


  def update
    @additional_exam = AdditionalExam.find params[:id], :include => :additional_exam_group
    @subjects = @additional_exam_group.batch.subjects

    if @additional_exam.update_attributes(params[:additional_exam])
      flash[:notice] = "#{t('flash3')}"
      redirect_to [@additional_exam_group, @additional_exam]
    else
      render 'edit'
    end
  end

  def destroy
    @additional_exam = AdditionalExam.find params[:id], :include => :additional_exam_group
    batch_id = @additional_exam.additional_exam_group.batch_id
    batch_event = BatchEvent.find_by_event_id_and_batch_id(@additional_exam.event_id,batch_id)
    event = Event.find(@additional_exam.event_id)
    if @additional_exam.destroy
      event.destroy
      batch_event.destroy
      flash[:notice] = "#{t('flash2')}"
    end
    redirect_to [@batch, @additional_exam_group]
  end

  private
  def query_data
    @additional_exam_group = AdditionalExamGroup.find(params[:additional_exam_group_id], :include => :batch)
    @batch = @additional_exam_group.batch
    @course = @batch.course
  end




end
