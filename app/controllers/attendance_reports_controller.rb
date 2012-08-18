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
  before_filter :default_time_zone_present_time


  def index
    if current_user.admin?
      @batches = Batch.active
    elsif @current_user.privileges.map{|p| p.name}.include?('StudentAttendanceView')
      @batches = Batch.active
    elsif @current_user.employee?
      @batches=Batch.find_all_by_employee_id @current_user.employee_record.id
      @batches+=@current_user.employee_record.subjects.collect{|b| b.batch}
      @batches=@batches.uniq unless @batches.empty?
    end
    @config = Configuration.find_by_config_key('StudentAttendanceType')
  end

  def subject
    @batch = Batch.find params[:batch_id]

    if @current_user.employee? and @allow_access ==true
      role_symb = @current_user.role_symbols
      if role_symb.include?(:student_attendance_view) or role_symb.include?(:student_attendance_register)
        @subjects= Subject.find(:all,:conditions=>"batch_id = '#{@batch.id}' ")
      else
        if @batch.employee_id.to_i==@current_user.employee_record.id
          @subjects= @batch.subjects
        else
          @subjects= Subject.find(:all,:joins=>"INNER JOIN employees_subjects ON employees_subjects.subject_id = subjects.id AND employee_id = #{@current_user.employee_record.id} AND batch_id = #{@batch.id} ")
        end
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
    @end_date = @local_tzone_time.to_date
    @leaves=Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
    @mode = params[:mode]
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    unless @config.config_value == 'Daily'
      if @mode == 'Overall'
        #        @academic_days=@batch.academic_days.count
        @students = @batch.students.by_first_name
        unless params[:subject_id] == '0'
          @subject = Subject.find params[:subject_id]
          unless @subject.elective_group_id.nil?
            @students = @subject.students.by_first_name
          end
          #          @academic_days=Timetable.tte_for_range(@batch,@start_date,@subject)
          @academic_days=@batch.subject_hours(@start_date, @end_date, params[:subject_id]).values.flatten.compact.count
          @subject = Subject.find params[:subject_id]
          @report = SubjectLeave.count(:conditions=>{:subject_id=>@subject.id,:batch_id=>@batch.id, :month_date => @start_date..@end_date})
          ##          @grouped = SubjectLeave.find_all_by_subject_id(@subject.id,  :conditions =>{:month_date => @start_date..@end_date}).group_by(&:student_id)
          @grouped = SubjectLeave.count(:conditions=>{:subject_id=>params[:subject_id],:batch_id=>@batch.id,:month_date => @start_date..@end_date},:group=>:student_id)
          @batch.students.by_first_name.each do |s|
            if @grouped[s.id].nil?
              @leaves[s.id]['leave']=0
            else
              @leaves[s.id]['leave']=@grouped[s.id]
            end
            @leaves[s.id]['total'] = (@academic_days - @leaves[s.id]['leave'])
            @leaves[s.id]['percent'] = (@leaves[s.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
          end
        else
          @academic_days=@batch.subject_hours(@start_date, @end_date, 0).values.flatten.compact.count
          @report = @batch.subject_leaves.find(:all,:conditions =>{:batch_id=>@batch.id,:month_date => @start_date..@end_date})
          @grouped = @batch.subject_leaves(:all,  :conditions =>{:batch_id=>@batch.id,:month_date => @start_date..@end_date}).group_by(&:student_id)
          @batch.students.each do |s|
            if @grouped[s.id].nil?
              @leaves[s.id]['leave']=0
            else
              @leaves[s.id]['leave']=@grouped[s.id].count
            end
            @leaves[s.id]['total'] = (@academic_days - @leaves[s.id]['leave'])
            @leaves[s.id]['percent'] = (@leaves[s.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
          end
        end
        render :update do |page|
          page.replace_html 'report', :partial => 'report'
          page.replace_html 'month', :text => ''
          page.replace_html 'year', :text => ''
        end
      else
        @year = @local_tzone_time.to_date.year
        @academic_days=@batch.working_days(@local_tzone_time.to_date).count
        @subject = params[:subject_id]
        render :update do |page|
          page.replace_html 'month', :partial => 'month'
        end
      end
    else
      if @mode == 'Overall'
        @academic_days=@batch.academic_days.count
        @students = @batch.students.by_first_name
        leaves_forenoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>true,:afternoon=>false,:month_date => @start_date..@end_date},:group=>:student_id)
        leaves_afternoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>false,:afternoon=>true,:month_date => @start_date..@end_date},:group=>:student_id)
        leaves_full=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>true,:afternoon=>true,:month_date => @start_date..@end_date},:group=>:student_id)
        @students.each do |student|
          @leaves[student.id]['total']=@academic_days-leaves_full[student.id].to_f-(0.5*(leaves_forenoon[student.id].to_f+leaves_afternoon[student.id].to_f))
          @leaves[student.id]['percent'] = (@leaves[student.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
        end
        render :update do |page|
          page.replace_html 'report', :partial => 'report'
          page.replace_html 'month', :text => ''
          page.replace_html 'year', :text => ''
        end
      else
        @year = @local_tzone_time.to_date.year
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
      @year = @local_tzone_time.to_date.year
      @month = params[:month]
      render :update do |page|
        page.replace_html 'year', :partial => 'year'
      end
    end
  end

  def report2
    @batch = Batch.find params[:batch_id]
    @month = params[:month]
    @year = params[:year]
    @students = @batch.students.by_first_name
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    #    @date = "01-#{@month}-#{@year}"
    @date = '01-'+@month+'-'+@year
    @start_date = @date.to_date
    @today = @local_tzone_time.to_date
    working_days=@batch.working_days(@date.to_date)
    unless @start_date > @local_tzone_time.to_date
      if @month == @today.month.to_s
        @end_date = @local_tzone_time.to_date
      else
        @end_date = @start_date.end_of_month
      end
      @academic_days=  working_days.select{|v| v<=@end_date}.count
      if @config.config_value == 'Daily'
        @report = @batch.attendances.find(:all,:conditions =>{:month_date => @start_date..@end_date})
      else
        unless params[:subject_id] == '0'
          @subject = Subject.find params[:subject_id]
          @report = SubjectLeave.find_all_by_subject_id(@subject.id,  :conditions =>{:batch_id=>@batch.id,:month_date => @start_date..@end_date})
        else
          @report = @batch.subject_leaves.find(:all,:conditions =>{:batch_id=>@batch.id,:month_date => @start_date..@end_date})
        end
      end
    else
      @report = ''
    end
    render :update do |page|
      page.replace_html 'report', :partial => 'report'
    end
  end

  def report
    @batch = Batch.find params[:batch_id]
    @month = params[:month]
    @year = params[:year]
    @students = @batch.students.by_first_name
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    #    @date = "01-#{@month}-#{@year}"
    @date = '01-'+@month+'-'+@year
    @start_date = @date.to_date
    @today = @local_tzone_time.to_date
    if (@start_date<@batch.start_date.to_date.beginning_of_month || @start_date>@batch.end_date.to_date || @start_date>=@today.next_month.beginning_of_month)
      render :update do |page|
        page.replace_html 'report', :text => t('no_reports')
      end
    else
      @leaves=Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
      working_days=@batch.working_days(@date.to_date)
      unless @start_date > @local_tzone_time.to_date
        if @month == @today.month.to_s
          @end_date = @local_tzone_time.to_date
        else
          @end_date = @start_date.end_of_month
        end
        if @config.config_value == 'Daily'
          @academic_days=  working_days.select{|v| v<=@end_date}.count
          @students = @batch.students.by_first_name
          leaves_forenoon=Attendance.count(:all,:joins=>:student,:conditions=>{:batch_id=>@batch.id,:forenoon=>true,:afternoon=>false,:month_date => @start_date..@end_date},:group=>:student_id)
          leaves_afternoon=Attendance.count(:all,:joins=>:student,:conditions=>{:batch_id=>@batch.id,:forenoon=>false,:afternoon=>true,:month_date => @start_date..@end_date},:group=>:student_id)
          leaves_full=Attendance.count(:all,:joins=>:student,:conditions=>{:batch_id=>@batch.id,:forenoon=>true,:afternoon=>true,:month_date => @start_date..@end_date},:group=>:student_id)
          @students.each do |student|
            @leaves[student.id]['total']=@academic_days-leaves_full[student.id].to_f-(0.5*(leaves_forenoon[student.id].to_f+leaves_afternoon[student.id].to_f))
            @leaves[student.id]['percent'] = (@leaves[student.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
          end
        else
          unless params[:subject_id] == '0'
            @subject = Subject.find params[:subject_id]
            unless @subject.elective_group_id.nil?
              @students = @subject.students.by_first_name
            end
            @academic_days=@batch.subject_hours(@start_date, @end_date, params[:subject_id]).values.flatten.compact.count
            @report = SubjectLeave.find_all_by_subject_id(@subject.id,  :conditions =>{:batch_id=>@batch.id,:month_date => @start_date..@end_date})
            @grouped = SubjectLeave.find_all_by_subject_id(@subject.id,  :conditions =>{:batch_id=>@batch.id,:month_date => @start_date..@end_date}).group_by(&:student_id)
            @batch.students.by_first_name.each do |s|
              if @grouped[s.id].nil?
                @leaves[s.id]['leave']=0
              else
                @leaves[s.id]['leave']=@grouped[s.id].count
              end
              @leaves[s.id]['total'] = (@academic_days - @leaves[s.id]['leave'])
              @leaves[s.id]['percent'] = (@leaves[s.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
            end
          else
            @academic_days=@batch.subject_hours(@start_date, @end_date, 0).values.flatten.compact.count
            @report = @batch.subject_leaves.find(:all,:conditions =>{:month_date => @start_date..@end_date})
            @grouped = @batch.subject_leaves(:all,  :conditions =>{:month_date => @start_date..@end_date}).group_by(&:student_id)
            @batch.students.by_first_name.each do |s|
              if @grouped[s.id].nil?
                @leaves[s.id]['leave']=0
              else
                @leaves[s.id]['leave']=@grouped[s.id].count
              end
              @leaves[s.id]['total'] = (@academic_days - @leaves[s.id]['leave'])
              @leaves[s.id]['percent'] = (@leaves[s.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
            end
          end
        end
      else
        @report = ''
      end
      render :update do |page|
        page.replace_html 'report', :partial => 'report'
      end
    end
  end

  def student_details
    @student = Student.find params[:id]
    @batch = @student.batch
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    if @config.config_value == 'Daily'
      @report = Attendance.find(:all,:conditions=>{:student_id=>@student.id,:batch_id=>@batch.id})
    else
      @report = SubjectLeave.find(:all,:conditions=>{:student_id=>@student.id,:batch_id=>@batch.id})
      
    end
  end

  def filter
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    @batch = Batch.find(params[:filter][:batch])
    @students = @batch.students.by_first_name
    @start_date = (params[:filter][:start_date]).to_date
    @end_date = (params[:filter][:end_date]).to_date
    @range = (params[:filter][:range])
    @value = (params[:filter][:value])
    @leaves=Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
    #    @academic_days=  @working_days.select{|v| v<=@end_date}.count
    @today = @local_tzone_time.to_date
    @mode=params[:filter][:report_type]
    working_days=@batch.working_days(@start_date.to_date)
    if request.post?
      unless @start_date > @local_tzone_time.to_date
        unless @config.config_value == 'Daily'
          unless params[:filter][:subject] == '0'
            @subject = Subject.find params[:filter][:subject]
            @academic_days=@batch.subject_hours(@start_date, @end_date, params[:filter][:subject]).values.flatten.compact.count
            @report = SubjectLeave.find_all_by_subject_id(@subject.id,  :conditions =>{:batch_id=>@batch.id,:month_date => @start_date..@end_date})
            @grouped = SubjectLeave.find_all_by_subject_id(@subject.id,  :conditions =>{:batch_id=>@batch.id,:month_date => @start_date..@end_date}).group_by(&:student_id)
            @batch.students.by_first_name.each do |s|
              if @grouped[s.id].nil?
                @leaves[s.id]['leave']=0
              else
                @leaves[s.id]['leave']=@grouped[s.id].count
              end
              @leaves[s.id]['total'] = (@academic_days - @leaves[s.id]['leave'])
              @leaves[s.id]['percent'] = (@leaves[s.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
            end
          else
            @academic_days=@batch.subject_hours(@start_date, @end_date, 0).values.flatten.compact.count
            @report = @batch.subject_leaves.find(:all,:conditions =>{:month_date => @start_date..@end_date})
            @grouped = @batch.subject_leaves(:all,  :conditions =>{:month_date => @start_date..@end_date}).group_by(&:student_id)
            @batch.students.by_first_name.each do |s|
              if @grouped[s.id].nil?
                @leaves[s.id]['leave']=0
              else
                @leaves[s.id]['leave']=@grouped[s.id].count
              end
              @leaves[s.id]['total'] = (@academic_days - @leaves[s.id]['leave'])
              @leaves[s.id]['percent'] = (@leaves[s.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
            end
          end
        else
          if @mode=='Overall'
            #            @working_days=@batch.academic_days.count
            @academic_days=@batch.academic_days.count
          else
            working_days=@batch.working_days(@start_date.to_date)
            #            @working_days=  working_days.select{|v| v<=@end_date}.count
            @academic_days=  working_days.select{|v| v<=@end_date}.count
          end
          @students = @batch.students.by_first_name
          leaves_forenoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>true,:afternoon=>false,:month_date => @start_date..@end_date},:group=>:student_id)
          leaves_afternoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>false,:afternoon=>true,:month_date => @start_date..@end_date},:group=>:student_id)
          leaves_full=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>true,:afternoon=>true,:month_date => @start_date..@end_date},:group=>:student_id)
          @students.each do |student|
            @leaves[student.id]['total']=@academic_days-leaves_full[student.id].to_f-(0.5*(leaves_forenoon[student.id].to_f+leaves_afternoon[student.id].to_f))
            @leaves[student.id]['percent'] = (@leaves[student.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
          end
          #          @report = @batch.attendances.find(:all,:conditions =>{:month_date => @start_date..@end_date})
          #          @report = @batch.attendances.find(:all,:conditions =>{:month_date => @start_date..@end_date})
        end
      end
    end
  end

  def filter2
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    @batch = Batch.find(params[:filter][:batch])
    @students = @batch.students.by_first_name
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
          @report = @batch.subject_leaves.find(:all,:conditions =>{:month_date => @start_date..@end_date})
        else
          @report = SubjectLeave.find_all_by_subject_id(@subject.id,  :conditions =>{:month_date => @start_date..@end_date})
        end
      else
        @report = @batch.attendances.find(:all,:conditions =>{:month_date => @start_date..@end_date})
      end
    end
  end

  def advance_search
    @batches = []
  end

  def report_pdf
    @config = Configuration.find_by_config_key('StudentAttendanceType')
    @batch = Batch.find(params[:filter][:batch])
    @students = @batch.students.by_first_name
    @start_date = (params[:filter][:start_date]).to_date
    @end_date = (params[:filter][:end_date]).to_date
    @range = (params[:filter][:range])
    @value = (params[:filter][:value])
    @leaves=Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
    @today = @local_tzone_time.to_date
    @mode=params[:filter][:report_type]
    working_days=@batch.working_days(@start_date.to_date)
    unless @start_date > @local_tzone_time.to_date
      unless @config.config_value == 'Daily'
        unless params[:filter][:subject] == '0'
          @subject = Subject.find params[:filter][:subject]
          @academic_days=@batch.subject_hours(@start_date, @end_date, params[:filter][:subject]).values.flatten.compact.count
          @grouped = SubjectLeave.find_all_by_subject_id(@subject.id,  :conditions =>{:month_date => @start_date..@end_date}).group_by(&:student_id)
          @batch.students.by_first_name.each do |s|
            if @grouped[s.id].nil?
              @leaves[s.id]['leave']=0
            else
              @leaves[s.id]['leave']=@grouped[s.id].count
            end
            @leaves[s.id]['total'] = (@academic_days - @leaves[s.id]['leave'])
            @leaves[s.id]['percent'] = (@leaves[s.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
          end
        else
          @academic_days=@batch.subject_hours(@start_date, @end_date, 0).values.flatten.compact.count
          @grouped = @batch.subject_leaves(:all,  :conditions =>{:month_date => @start_date..@end_date}).group_by(&:student_id)
          @batch.students.each do |s|
            if @grouped[s.id].nil?
              @leaves[s.id]['leave']=0
            else
              @leaves[s.id]['leave']=@grouped[s.id].count
            end
            @leaves[s.id]['total'] = (@academic_days - @leaves[s.id]['leave'])
            @leaves[s.id]['percent'] = (@leaves[s.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
          end
        end
      else
        if @mode=='Overall'
          #            @working_days=@batch.academic_days.count
          @academic_days=@batch.academic_days.count
        else
          working_days=@batch.working_days(@start_date.to_date)
          #            @working_days=  working_days.select{|v| v<=@end_date}.count
          @academic_days=  working_days.select{|v| v<=@end_date}.count
        end
        @students = @batch.students.by_first_name
        leaves_forenoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>true,:afternoon=>false,:month_date => @start_date..@end_date},:group=>:student_id)
        leaves_afternoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>false,:afternoon=>true,:month_date => @start_date..@end_date},:group=>:student_id)
        leaves_full=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>true,:afternoon=>true,:month_date => @start_date..@end_date},:group=>:student_id)
        @students.each do |student|
          @leaves[student.id]['total']=@academic_days-leaves_full[student.id].to_f-(0.5*(leaves_forenoon[student.id].to_f+leaves_afternoon[student.id].to_f))
          @leaves[student.id]['percent'] = (@leaves[student.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
        end
        #        @report = @batch.attendances.find(:all,:conditions =>{:month_date => @start_date..@end_date})
        #          @report = @batch.attendances.find(:all,:conditions =>{:month_date => @start_date..@end_date})
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
    @students = @batch.students.by_first_name
    @start_date = (params[:filter][:start_date]).to_date
    @end_date = (params[:filter][:end_date]).to_date
    @range = (params[:filter][:range])
    @value = (params[:filter][:value])
    @mode=params[:filter][:report_type]
    @leaves=Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }

    if request.post?
      unless @start_date > @local_tzone_time.to_date
        unless @config.config_value == 'Daily'
          unless params[:filter][:subject] == '0'
            @subject = Subject.find params[:filter][:subject]
            @academic_days=@batch.subject_hours(@start_date, @end_date, params[:filter][:subject]).values.flatten.compact.count
            @grouped = SubjectLeave.find_all_by_subject_id(@subject.id,  :conditions =>{:month_date => @start_date..@end_date}).group_by(&:student_id)
            @batch.students.by_first_name.each do |s|
              if @grouped[s.id].nil?
                @leaves[s.id]['leave']=0
              else
                @leaves[s.id]['leave']=@grouped[s.id].count
              end
              @leaves[s.id]['total'] = (@academic_days - @leaves[s.id]['leave'])
              @leaves[s.id]['percent'] = (@leaves[s.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
            end
          else
            @academic_days=@batch.subject_hours(@start_date, @end_date, 0).values.flatten.compact.count
            @grouped = @batch.subject_leaves(:all,  :conditions =>{:month_date => @start_date..@end_date}).group_by(&:student_id)
            @batch.students.by_first_name.each do |s|
              if @grouped[s.id].nil?
                @leaves[s.id]['leave']=0
              else
                @leaves[s.id]['leave']=@grouped[s.id].count
              end
              @leaves[s.id]['total'] = (@academic_days - @leaves[s.id]['leave'])
              @leaves[s.id]['percent'] = (@leaves[s.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
            end
          end
        else
          if @mode=='Overall'
            #            @working_days=@batch.academic_days.count
            @academic_days=@batch.academic_days.count
          else
            working_days=@batch.working_days(@start_date.to_date)
            #            @working_days=  working_days.select{|v| v<=@end_date}.count
            @academic_days=  working_days.select{|v| v<=@end_date}.count
          end
          @students = @batch.students.by_first_name
          leaves_forenoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>true,:afternoon=>false,:month_date => @start_date..@end_date},:group=>:student_id)
          leaves_afternoon=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>false,:afternoon=>true,:month_date => @start_date..@end_date},:group=>:student_id)
          leaves_full=Attendance.count(:all,:conditions=>{:batch_id=>@batch.id,:forenoon=>true,:afternoon=>true,:month_date => @start_date..@end_date},:group=>:student_id)
          @students.each do |student|
            @leaves[student.id]['total']=@academic_days-leaves_full[student.id].to_f-(0.5*(leaves_forenoon[student.id].to_f+leaves_afternoon[student.id].to_f))
            @leaves[student.id]['percent'] = (@leaves[student.id]['total'].to_f/@academic_days)*100 unless @academic_days == 0
          end
          #        @report = @batch.attendances.find(:all,:conditions =>{:month_date => @start_date..@end_date})
          #          @report = @batch.attendances.find(:all,:conditions =>{:month_date => @start_date..@end_date})
        end
      else
        @report = ''
      end
    end
    render :pdf => 'filter_report_pdf'
            


    #    respond_to do |format|
    #      format.pdf { render :layout => false }
    #    end
  end
end