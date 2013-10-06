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
class CceReportsController < ApplicationController
  before_filter :login_required
  filter_access_to :all

  def index

  end

  def create_reports
    @courses = Course.cce
    if request.post?
      if params[:course][:batch_ids].present?
        notice, errors = Batch.create_reports(params[:course][:batch_ids])
        flash[:notice] = notice
        flash[:error] = errors
      else
        flash[:notice] = "No batch selected"
      end
    end
  end

  def student_wise_report
    @batches = Batch.cce
    if request.post?
      @batch = Batch.find(params[:batch_id])
      @students = @batch.students.all(:order => "first_name ASC")
      @student = @students.first
      fetch_report if @student
      render(:update) do |page|
        page.replace_html 'student_list', partial: "student_list", object: @students
        if @student.nil?
          page.replace_html 'report', text: ""
        else
          page.replace_html 'report', partial: "student_report"
        end
        page.replace_html 'hider', text: ''
      end
    end
  end

  def student_report
    @student = Student.find(params[:student])
    @batch = @student.batch
    fetch_report
    render(:update) do |page|
      page.replace_html   'report', :partial=>"student_report"
    end
  end

  def student_report_pdf
    @student = CceReport.find_student(params[:type], params[:id])
    @type = params[:type] || "regular"
    @batch = Batch.find(params[:batch_id])
    @student.batch_in_context = @batch
    fetch_report
    render :pdf => "#{@student.first_name}-CCE_Report"
  end

  def student_transcript
    @student = CceReport.find_student(params[:type], params[:id])
    @type = params[:type] || "regular"
    @batch = (params[:batch_id].blank? ? @student.batch : Batch.find(params[:batch_id]))
    @batches = @student.all_batches.reverse unless request.xhr?
    @student.batch_in_context = @batch
    fetch_report
    if request.xhr?
      render(:update) do |page|
        page.replace_html   'report', :partial=>"student_report"
      end
    end
  end

  private

  def fetch_report
    @report = @student.individual_cce_report_cached
    @subjects = @student.all_subjects.select{|x| x.no_exams == false}
    @exam_groups = ExamGroup.find_all_by_id(@report.exam_group_ids, :include => :cce_exam_category)
    coscholastic = @report.coscholastic
    @observation_group_ids = coscholastic.map(&:observation_group_id)
    @observation_groups = ObservationGroup.find_all_by_id(@observation_group_ids).map(&:name)
    @co_hash = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
    @obs_groups = @batch.observation_groups.to_a
    @og = @obs_groups.group_by(&:observation_kind)
    @co_hashi = {}
    @og.each do |kind, ogs|
      id_list = ogs.map(&:id)
      @co_hashi[kind] = coscholastic.map do |cs|
        cs if id_list.include?(cs.observation_group_id)
      end.compact
    end
  end

end
