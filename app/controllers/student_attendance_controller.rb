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

class StudentAttendanceController < ApplicationController
  before_filter :login_required
  before_filter :only_assigned_employee_allowed
  before_filter :protect_other_student_data

 
  def index
  end

  def student
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    @student = Student.find(params[:id])
    @batch = Batch.find(@student.batch_id)
    @subjects = Subject.find_all_by_batch_id(@batch.id,:conditions=>'is_deleted = false')
    @electives = @subjects.map{|x|x unless x.elective_group_id.nil?}.compact
    @electives.reject! { |z| z.students.include?(@student)  }
    @subjects -= @electives

    if request.post?
      @detail_report = []
      if params[:advance_search][:mode]== 'Overall'
        @start_date = @batch.start_date.to_date
        @end_date = Date.today
        unless @config.config_value == 'Daily'
          unless params[:advance_search][:subject_id].empty?
            @academic_days=@batch.subject_hours(@start_date, @end_date, params[:advance_search][:subject_id]).values.flatten.compact.count
            @subject=Subject.find(params[:advance_search][:subject_id])
            @student_leaves = SubjectLeave.find(:all,:conditions =>{:subject_id=>@subject.id,:student_id=>@student.id,:month_date => @start_date..@end_date})
          else
            @academic_days=@batch.subject_hours(@start_date, @end_date, 0).values.flatten.compact.count
            @student_leaves = SubjectLeave.find(:all,  :conditions =>{:student_id=>@student.id,:month_date => @start_date..@end_date})
          end
          @leaves= @student_leaves.count
          @leaves||=0
          @attendance = (@academic_days - @leaves)
          @percent = (@attendance.to_f/@academic_days)*100 unless @academic_days == 0
        else
          @student_leaves = Attendance.find(:all,  :conditions =>{:batch_id=>@batch.id,:student_id=>@student.id,:month_date => @start_date..@end_date})
          @academic_days=@batch.academic_days.select{|v| v<=@end_date}.count
          leaves_forenoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:student_id=>@student.id,:forenoon=>true,:afternoon=>false,:month_date => @start_date..@end_date})
          leaves_afternoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:student_id=>@student.id,:forenoon=>false,:afternoon=>true,:month_date => @start_date..@end_date})
          leaves_full=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:student_id=>@student.id,:forenoon=>true,:afternoon=>true,:month_date => @start_date..@end_date})
          @leaves=leaves_full.to_f+(0.5*(leaves_forenoon.to_f+leaves_afternoon.to_f))
          @attendance = (@academic_days - @leaves)
          @percent = (@attendance.to_f/@academic_days)*100 unless @academic_days == 0
        end
      elsif params[:advance_search][:mode]== 'Monthly'
        @month = params[:advance_search][:month]
        @year = params[:advance_search][:year]
        @start_date = "01-#{@month}-#{@year}".to_date
        #        @start_date = @date
        @today = Date.today
        @end_date = @start_date.end_of_month
        if @end_date > Date.today
          @end_date = Date.today
        end
        unless @config.config_value == 'Daily'
          unless params[:advance_search][:subject_id].empty?
            @academic_days=@batch.subject_hours(@start_date, @end_date, params[:advance_search][:subject_id]).values.flatten.compact.count
            @subject=Subject.find(params[:advance_search][:subject_id])
            @student_leaves = SubjectLeave.find(:all,:conditions =>{:subject_id=>@subject.id,:student_id=>@student.id,:month_date => @start_date..@end_date})
          else
            @academic_days=@batch.subject_hours(@start_date, @end_date, 0).values.flatten.compact.count
            @student_leaves = SubjectLeave.find(:all,  :conditions =>{:student_id=>@student.id,:month_date => @start_date..@end_date})
          end
          @leaves= @student_leaves.count
          @leaves||=0
          @attendance = (@academic_days - @leaves)
          @percent = (@attendance.to_f/@academic_days)*100 unless @academic_days == 0
        else
          @student_leaves = Attendance.find(:all,  :conditions =>{:batch_id=>@batch.id,:student_id=>@student.id,:month_date => @start_date..@end_date})
          @academic_days=@batch.working_days(@start_date.to_date).select{|v| v<=@end_date}.count
          leaves_forenoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:student_id=>@student.id,:forenoon=>true,:afternoon=>false,:month_date => @start_date..@end_date})
          leaves_afternoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:student_id=>@student.id,:forenoon=>false,:afternoon=>true,:month_date => @start_date..@end_date})
          leaves_full=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:student_id=>@student.id,:forenoon=>true,:afternoon=>true,:month_date => @start_date..@end_date})
          @leaves=leaves_full.to_f+(0.5*(leaves_forenoon.to_f+leaves_afternoon.to_f))
          @attendance = (@academic_days - @leaves)
          @percent = (@attendance.to_f/@academic_days)*100 unless @academic_days == 0
        end
      else
        render :update do |page|
          page.replace_html 'error-container', :text => "<div id='errorExplanation' class='errorExplanation'><p>#{t('please_select_mode')}.</p></div>"
        end
        return
      end
      
      render :update do |page|
        page.replace_html 'report', :partial => 'report'
        page.replace_html 'error-container', :text => ''
      end
    end
    
  end

  def month
    if params[:mode] == 'Monthly'
      @year = Date.today.year
      render :update do |page|
        page.replace_html 'month', :partial => 'month'
        page.replace_html 'error-container', :text => ''
      end
    else
      render :update do |page|
        page.replace_html 'month', :text =>''
        page.replace_html 'error-container', :text => ''
      end
    end
  end

  def student_report
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    @student = Student.find(params[:id])
    @batch = Batch.find(params[:year])
    @start_date = @batch.start_date.to_date
    @end_date =  @batch.end_date.to_date
    unless @config.config_value == 'Daily'
      @academic_days=@batch.subject_hours(@start_date, @end_date, 0).values.flatten.compact.count
      @student_leaves = SubjectLeave.find(:all,  :conditions =>{:batch_id=>@batch.id,:student_id=>@student.id,:month_date => @start_date..@end_date})
      @leaves= @student_leaves.count
      @leaves||=0
      @attendance = (@academic_days - @leaves)
      @percent = (@attendance.to_f/@academic_days)*100 unless @academic_days == 0
    else
      @student_leaves = Attendance.find(:all,  :conditions =>{:student_id=>@student.id,:month_date => @start_date..@end_date})
      @academic_days=@batch.academic_days.select{|v| v<=@end_date}.count
      leaves_forenoon=Attendance.count(:all,:conditions=>{:student_id=>@student.id,:forenoon=>true,:afternoon=>false,:month_date => @start_date..@end_date})
      leaves_afternoon=Attendance.count(:all,:conditions=>{:student_id=>@student.id,:forenoon=>false,:afternoon=>true,:month_date => @start_date..@end_date})
      leaves_full=Attendance.count(:all,:conditions=>{:student_id=>@student.id,:forenoon=>true,:afternoon=>true,:month_date => @start_date..@end_date})
      @leaves=leaves_full.to_f+(0.5*(leaves_forenoon.to_f+leaves_afternoon.to_f))
      @attendance = (@academic_days - @leaves)
      @percent = (@attendance.to_f/@academic_days)*100 unless @academic_days == 0
    end

  end

end