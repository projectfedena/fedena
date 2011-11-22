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

class AttendanceReportsController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  before_filter :only_assigned_employee_allowed

  def index
    @batches = Batch.active
    @config = Configuration.find_by_config_key('StudentAttendanceType')
  end

  def subject
    @batch = Batch.find params[:batch_id]

    if @current_user.employee? and @allow_access ==true
      role_symb = @current_user.role_symbols
      if role_symb.include?(:student_attendance_view) or role_symb.include?(:student_attendance_register)
        @subjects= Subject.find(:all,:conditions=>"batch_id = '#{@batch.id}' ")
      else
        @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
      end
    else
      @subjects = Subject.find_all_by_batch_id(@batch.id,:conditions=>'is_deleted = false')
    end

    render :update do |page|
      page.replace_html 'subject', :partial => 'subject'
    end
  end

  def mode
    @batch = Batch.find params[:batch_id]
    unless params[:subject_id] == ''
      @subject = params[:subject_id]
    else
      @subject = 0
    end
    render :update do |page|
      page.replace_html 'mode', :partial => 'mode'
      page.replace_html 'month', :text => ''
    end
  end
  def show
    @batch = Batch.find params[:batch_id]
    @start_date = @batch.start_date.to_date
    @end_date = Date.today.to_date
    
    @mode = params[:mode]
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    unless @config.config_value == 'Daily'
      if @mode == 'Overall'
        @students = Student.find_all_by_batch_id(@batch.id)
        unless params[:subject_id] == '0'
          @subject = Subject.find params[:subject_id]
          @report = PeriodEntry.find_all_by_subject_id(@subject.id,  :conditions =>{:month_date => @start_date..@end_date})
        else
          @report = PeriodEntry.find_all_by_batch_id(@batch.id,  :conditions =>{:month_date => @start_date..@end_date})
        end
        render :update do |page|
          page.replace_html 'report', :partial => 'report'
          page.replace_html 'month', :text => ''
          page.replace_html 'year', :text => ''
        end
      else
        @year = Date.today.year
        @subject = params[:subject_id]
        render :update do |page|
          page.replace_html 'month', :partial => 'month'
        end
      end
    else
      if @mode == 'Overall'
        @students = Student.find_all_by_batch_id(@batch.id)
        @report = PeriodEntry.find_all_by_batch_id(@batch.id,  :conditions =>{:month_date => @start_date..@end_date})
        render :update do |page|
          page.replace_html 'report', :partial => 'report'
          page.replace_html 'month', :text => ''
          page.replace_html 'year', :text => ''
        end
      else
        @year = Date.today.year
        @subject = params[:subject_id]
        render :update do |page|
          page.replace_html 'month', :partial => 'month'
        end
      end
    end
  end
  def year
    @batch = Batch.find params[:batch_id]
    @subject = params[:subject_id]
    if request.xhr?
      @year = Date.today.year
      @month = params[:month]
      render :update do |page|
        page.replace_html 'year', :partial => 'year'
      end
    end
  end

  def report
    @batch = Batch.find params[:batch_id]
    @month = params[:month]
    @year = params[:year]
    @students = Student.find_all_by_batch_id(@batch.id)
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    #    @date = "01-#{@month}-#{@year}"
    @date = '01-'+@month+'-'+@year
    @start_date = @date.to_date
    @today = Date.today
    unless @start_date > Date.today
      if @month == @today.month.to_s
        @end_date = Date.today
      else
        @end_date = @start_date.end_of_month
      end
      
      if @config.config_value == 'Daily'
        @report = PeriodEntry.find_all_by_batch_id(@batch.id,  :conditions =>{:month_date => @start_date..@end_date})
      else
        unless params[:subject_id] == '0'
          @subject = Subject.find params[:subject_id]
          @report = PeriodEntry.find_all_by_subject_id(@subject.id,  :conditions =>{:month_date => @start_date..@end_date})
        else
          @report = PeriodEntry.find_all_by_batch_id(@batch.id,  :conditions =>{:month_date => @start_date..@end_date})
        end
      end
    else
      @report = ''
    end
    render :update do |page|
      page.replace_html 'report', :partial => 'report'
    end
  end

  def student_details
    @student = Student.find params[:id]
    @report = Attendance.find_all_by_student_id(@student.id)
  end

  def filter
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    @batch = Batch.find(params[:filter][:batch])
    @students = Student.find_all_by_batch_id(@batch.id)
    @start_date = (params[:filter][:start_date]).to_date
    @end_date = (params[:filter][:end_date]).to_date
    @range = (params[:filter][:range])
    @value = (params[:filter][:value])
    if request.post?
      unless @config.config_value == 'Daily'
        unless params[:filter][:subject] == '0'
          @subject = Subject.find params[:filter][:subject]
        end
        if params[:filter][:subject] == '0'
          @report = PeriodEntry.find_all_by_batch_id(@batch.id,  :conditions =>{:month_date => @start_date..@end_date})
        else
          @report = PeriodEntry.find_all_by_subject_id(@subject.id,  :conditions =>{:month_date => @start_date..@end_date})
        end
      else
        @report = PeriodEntry.find_all_by_batch_id(@batch.id,  :conditions =>{:month_date => @start_date..@end_date})
      end
    end
  end

  def advance_search
    @batches = []
  end

  def report_pdf
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    @batch = Batch.find(params[:filter][:batch])
    @students = Student.find_all_by_batch_id(@batch.id)
    @start_date = (params[:filter][:start_date]).to_date
    @end_date = (params[:filter][:end_date]).to_date
    @range = (params[:filter][:range])
    @value = (params[:filter][:value])
    @students = Student.find_all_by_batch_id(@batch.id)
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    unless @start_date > Date.today
      if @config.config_value == 'Daily'
        @report = PeriodEntry.find_all_by_batch_id(@batch.id,  :conditions =>{:month_date => @start_date..@end_date})
      else
        unless params[:filter][:subject] == '0'
          @subject = Subject.find params[:filter][:subject]
          @report = PeriodEntry.find_all_by_subject_id(@subject.id,  :conditions =>{:month_date => @start_date..@end_date})
        else
          @report = PeriodEntry.find_all_by_batch_id(@batch.id,  :conditions =>{:month_date => @start_date..@end_date})
        end
      end
    else
      @report = ''
    end
    render :pdf => 'report_pdf'
             
    #    render :layout=>'pdf'
    #    respond_to do |format|
    #      format.pdf { render :layout => false }
    #    end
  end

  def filter_report_pdf
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    @batch = Batch.find(params[:filter][:batch])
    @students = Student.find_all_by_batch_id(@batch.id)
    @start_date = (params[:filter][:start_date]).to_date
    @end_date = (params[:filter][:end_date]).to_date
    @range = (params[:filter][:range])
    @value = (params[:filter][:value])
    if request.post?
      unless @config.config_value == 'Daily'
        unless params[:filter][:subject] == '0'
          @subject = Subject.find params[:filter][:subject]
        end
        if params[:filter][:subject] == '0'
          @report = PeriodEntry.find_all_by_batch_id(@batch.id,  :conditions =>{:month_date => @start_date..@end_date})
        else
          @report = PeriodEntry.find_all_by_subject_id(@subject.id,  :conditions =>{:month_date => @start_date..@end_date})
        end
      else
        @report = PeriodEntry.find_all_by_batch_id(@batch.id,  :conditions =>{:month_date => @start_date..@end_date})
      end
    end
    render :pdf => 'filter_report_pdf'
            


    #    respond_to do |format|
    #      format.pdf { render :layout => false }
    #    end
  end
end