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

class EmployeeAttendanceController < ApplicationController
  before_filter :login_required,:configuration_settings_for_hr
  before_filter :protect_leave_dashboard, :only => [:leaves]#, :employee_attendance_pdf]
  before_filter :protect_applied_leave, :only => [:own_leave_application, :cancel_application]
  before_filter :protect_manager_leave_application_view, :only => [:leave_application]
  before_filter :protect_leave_history, :only => [:leave_history,:update_leave_history]
  #    prawnto :prawn => {:left_margin => 25, :right_margin => 25}

  filter_access_to :all

  def add_leave_types
    @leave_types = EmployeeLeaveType.find(:all, :order => "name ASC",:conditions=>'status = 1')
    @inactive_leave_types = EmployeeLeaveType.find(:all, :order => "name ASC",:conditions=>'status = 0')
    @leave_type = EmployeeLeaveType.new(params[:leave_type])
    @employee = Employee.all
    if request.post? and @leave_type.save
      @employee.each do |e|
        EmployeeLeave.create( :employee_id => e.id, :employee_leave_type_id => @leave_type.id, :leave_count => @leave_type.max_leave_count)
      end
            flash[:notice] = t('flash1')
      redirect_to :action => "add_leave_types"
    end
  end

  def edit_leave_types
    @leave_type = EmployeeLeaveType.find(params[:id])
    if request.post? and @leave_type.update_attributes(params[:leave_type])
            flash[:notice] = t('flash2')
      redirect_to :action => "add_leave_types"
    end
  end

  def delete_leave_types
    @leave_type = EmployeeLeaveType.find(params[:id])
    @attendance = EmployeeAttendance.find_all_by_employee_leave_type_id(@leave_type.id)
    @leave_count = EmployeeLeave.find_all_by_employee_leave_type_id(@leave_type.id)
    if @attendance.blank?
      @leave_type.delete
      @leave_count.each do |e|
        e.delete
      end
            flash[:notice] = t('flash3')
    else
            flash[:notice] = "#{t('flash_msg12')}"
    end
    redirect_to :action => "add_leave_types"
    

  end

  def leave_reset_settings
    #  @config = Configuration.get_multiple_configs_as_hash ['AutomaticLeaveReset', 'LeaveResetPeriod', 'LastAutoLeaveReset']
    @auto_reset = Configuration.find_by_config_key('AutomaticLeaveReset')
    @reset_period = Configuration.find_by_config_key('LeaveResetPeriod')
    @last_reset = Configuration.find_by_config_key('LastAutoLeaveReset')
    @fin_start_date = Configuration.find_by_config_key('FinancialYearStartDate')
    if request.post?
      @auto_reset.update_attributes(:config_value=> params[:configuration][:automatic_leave_reset])
      @reset_period.update_attributes(:config_value=> params[:configuration][:leave_reset_period])
      @last_reset.update_attributes(:config_value=> params[:configuration][:financial_year_start_date])

            flash[:notice] = t('flash_msg8')
        end
    end
 
  def update_employee_leave_reset_all
    @leave_count = EmployeeLeave.all
    @leave_count.each do |e|
      @leave_type = EmployeeLeaveType.find_by_id(e.employee_leave_type_id)
      if @leave_type.status
        default_leave_count = @leave_type.max_leave_count
        if @leave_type.carry_forward
          leave_taken = e.leave_taken
          available_leave = e.leave_count
          if leave_taken <= available_leave
            balance_leave = available_leave - leave_taken
            available_leave = balance_leave.to_f
            available_leave += default_leave_count.to_f
            leave_taken = 0
            e.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
          else
            available_leave = default_leave_count.to_f
            leave_taken = 0
            e.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
          end
        else
          available_leave = default_leave_count.to_f
          leave_taken = 0
          e.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
        end
      end
    end
    render :update do |page|
            page.replace_html "main-reset-box", :text => "<p class='flash-msg'>#{t('leave_count_reset_sucessfull')}</p>"
    end
  end

  def employee_leave_reset_by_department
    @departments = EmployeeDepartment.find(:all, :conditions => "status = true", :order=> "name ASC")

  end

  def list_department_leave_reset
    @leave_types = EmployeeLeaveType.find(:all, :conditions => "status = true")
    if params[:department_id] == ""
      render :update do |page|
        page.replace_html "department-list", :text => ""
      end
      return
    end
    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    render :update do |page|
      page.replace_html "department-list", :partial => 'department_list'
    end
  end

  def update_department_leave_reset
    @employee = params[:employee_id]
    @employee.each do |e|
      @leave_count = EmployeeLeave.find_all_by_employee_id(e)
      @leave_count.each do |c|
        #attendance = EmployeeAttendance.find_all_by_employee_id(e, :conditions=> "employee_leave_type_id = '#{c.employee_leave_type_id }' and attendance_date >= '#{Date.today.strftime('%Y-%m-%d')}'" )
        @leave_type = EmployeeLeaveType.find_by_id(c.employee_leave_type_id)
        if @leave_type.status
          default_leave_count = @leave_type.max_leave_count
          if @leave_type.carry_forward
            leave_taken = c.leave_taken
            available_leave = c.leave_count
            if leave_taken <= available_leave
              balance_leave = available_leave - leave_taken
              available_leave = balance_leave.to_f
              available_leave += default_leave_count.to_f
              leave_taken = 0
#              unless attendance.blank?
#                attendance.each do |a|
#                  if a.is_half_day
#                    leave_taken += (0.5).to_f
#
#                  else
#                    leave_taken += (1).to_f
#
#                  end
#                end
#              end
              c.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
            else
              available_leave = default_leave_count.to_f
              leave_taken = 0
              c.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
            end
          else
            available_leave = default_leave_count.to_f
            leave_taken = 0
            c.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
          end
        end

      end
    end
        flash[:notice]=t('flash12')
    redirect_to :controller=>"employee_attendance", :action => "employee_leave_reset_by_department"
  end


  def employee_leave_reset_by_employee
    @departments = EmployeeDepartment.find(:all)
    @categories  = EmployeeCategory.find(:all)
    @positions   = EmployeePosition.find(:all)
    @grades      = EmployeeGrade.find(:all)
  end

  def employee_search_ajax
    other_conditions = ""
    other_conditions += " AND employee_department_id = '#{params[:employee_department_id]}'" unless params[:employee_department_id] == ""
    other_conditions += " AND employee_category_id = '#{params[:employee_category_id]}'" unless params[:employee_category_id] == ""
    other_conditions += " AND employee_position_id = '#{params[:employee_position_id]}'" unless params[:employee_position_id] == ""
    other_conditions += " AND employee_grade_id = '#{params[:employee_grade_id]}'" unless params[:employee_grade_id] == ""
    unless params[:query].length < 3
      @employee = Employee.find(:all,
        :conditions => ["(first_name LIKE ? OR middle_name LIKE ? OR last_name LIKE ?
                       OR employee_number LIKE ? OR (concat(first_name, \" \", last_name) LIKE ?))" + other_conditions,
                       "#{params[:query]}%","#{params[:query]}%","#{params[:query]}%",
                       "#{params[:query]}", "#{params[:query]}"],
        :order => "first_name asc") unless params[:query] == ''
    else
      @employee = Employee.find(:all,
        :conditions => ["employee_number = ? "+ other_conditions, "#{params[:query]}%"],
        :order => "first_name asc") unless params[:query] == ''
    end
    render :layout => false
  end

  def employee_view_all
    @departments = EmployeeDepartment.find(:all)
  end

  def employees_list
    department_id = params[:department_id]
    @employees = Employee.find_all_by_employee_department_id(department_id,:order=>'first_name ASC')

    render :update do |page|
      page.replace_html 'employee_list', :partial => 'employee_view_all_list', :object => @employees
    end
  end

  def employee_leave_details
    @employee = Employee.find_by_id(params[:id])
    @leave_count = EmployeeLeave.find_all_by_employee_id(@employee.id)
  end

  def employee_wise_leave_reset
    @employee = Employee.find_by_id(params[:id])
    @leave_count = EmployeeLeave.find_all_by_employee_id(@employee.id)
    @leave_count.each do |e|
      #attendance = EmployeeAttendance.find_all_by_employee_id(@employee.id, :conditions=> "employee_leave_type_id = '#{e.employee_leave_type_id }' and attendance_date >= '#{Date.today.strftime('%Y-%m-%d')}'" )
      @leave_type = EmployeeLeaveType.find_by_id(e.employee_leave_type_id)
      if @leave_type.status
        default_leave_count = @leave_type.max_leave_count
        if @leave_type.carry_forward
          leave_taken = e.leave_taken
          available_leave = e.leave_count
          if leave_taken <= available_leave
            balance_leave = available_leave - leave_taken
            available_leave = balance_leave.to_f
            available_leave += default_leave_count.to_f
            leave_taken = 0
            e.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
          else
            available_leave = default_leave_count.to_f
            leave_taken = 0
            e.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
          end
        else
          available_leave = default_leave_count.to_f
          leave_taken = 0
          e.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
        end
      end
    end
    render :update do |page|
            flash.now[:notice]= "#{t('flash_msg12')}"
      page.replace_html "list", :partial => 'employee_reset_sucess'
    end
  end


  def register
    @departments = EmployeeDepartment.find(:all, :conditions=>"status = true", :order=> "name ASC")
    if request.post?
      unless params[:employee_attendance].nil?
        params[:employee_attendance].each_pair do |emp, att|
          @employee_attendance = EmployeeAttendance.create(:attendance_date => params[:date],
            :employees_id => emp, :employee_leave_types_id=> att) unless att == ""
        end
                flash[:notice]=t('flash3')
        redirect_to :controller=>"employee_attendance", :action => "register"
      end
    end
  end

  def update_attendance_form
    @leave_types = EmployeeLeaveType.find(:all, :conditions=>"status = true", :order=>"name ASC")
    if params[:department_id] == ""
      render :update do |page|
        page.replace_html "attendance_form", :text => ""
      end
      return
    end

    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    render :update do |page|
      page.replace_html 'attendance_form', :partial => 'attendance_form'
    end
  end

  def report
    @departments = EmployeeDepartment.find(:all, :conditions => "status = true", :order=> "name ASC")
  end

  def update_attendance_report
    @leave_types = EmployeeLeaveType.find(:all, :conditions => "status = true")
    if params[:department_id] == ""
      render :update do |page|
        page.replace_html "attendance_report", :text => ""
      end
      return
    end
    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    render :update do |page|
      page.replace_html "attendance_report", :partial => 'attendance_report'
    end
  end

  def emp_attendance
    @employee = Employee.find(params[:id])
    @attendance_report = EmployeeAttendance.find_all_by_employee_id(@employee.id)
    @leave_types = EmployeeLeaveType.find(:all, :conditions => "status = true")
    @leave_count = EmployeeLeave.find_all_by_employee_id(@employee,:joins=>:employee_leave_type,:conditions=>"status = true")
    @total_leaves = 0
    @leave_types.each do |lt|
      leave_count = EmployeeAttendance.find_all_by_employee_id_and_employee_leave_type_id(@employee.id,lt.id).size
      @total_leaves = @total_leaves +leave_count
    end
  end

  def leave_history
    @employee = Employee.find(params[:id])
  end

  def update_leave_history
    @employee = Employee.find(params[:id])
    @start_date = (params[:period][:start_date])
    @end_date = (params[:period][:end_date])
    @leave_types = EmployeeLeaveType.find(:all, :conditions => "status = true")
    @employee_attendances = {}
    @leave_types.each do |lt|
      @employee_attendances[lt.name] = EmployeeAttendance.find_all_by_employee_id_and_employee_leave_type_id(@employee.id,lt.id,:conditions=> "attendance_date between '#{@start_date.to_date}' and '#{@end_date.to_date}'")
    end
    render :update do |page|
      page.replace_html "attendance-report", :partial => 'update_leave_history'
    end
  end

  def leaves
    @leave_types = EmployeeLeaveType.find(:all, :conditions=>"status = true")
    @employee = Employee.find(params[:id])
    @reporting_employees = Employee.find_all_by_reporting_manager_id(@employee.id)
    @total_leave_count = 0
    @reporting_employees.each do |e|
      @app_leaves = ApplyLeave.count(:conditions=>["employee_id =? AND viewed_by_manager =?", e.id, false])
      @total_leave_count = @total_leave_count + @app_leaves
    end

    @leave_apply = ApplyLeave.new(params[:leave_apply])
    if request.post? and @leave_apply.save
      ApplyLeave.update(@leave_apply, :approved=> false, :viewed_by_manager=> false)
            flash[:notice]=t('flash5')
      redirect_to :controller => "employee_attendance", :action=> "leaves", :id=>@employee.id
    end
  end

  def leave_application
    @applied_leave = ApplyLeave.find(params[:id])
    @applied_employee = Employee.find(@applied_leave.employee_id)
    @leave_type = EmployeeLeaveType.find(@applied_leave.employee_leave_types_id)
    @manager = @applied_employee.reporting_manager_id
    @leave_count = EmployeeLeave.find_by_employee_id(@applied_employee.id,:conditions=> "employee_leave_type_id = '#{@leave_type.id}'")
  end

  def leave_app
    @employee = Employee.find(params[:id2])
    @applied_leave = ApplyLeave.find(params[:id])
    @leave_type = EmployeeLeaveType.find(@applied_leave.employee_leave_types_id)
    @applied_employee = Employee.find(@applied_leave.employee_id)
    @manager = @applied_employee.reporting_manager_id
  end

  def approve_remarks
    @applied_leave = ApplyLeave.find(params[:id])
  end

  def deny_remarks
    @applied_leave = ApplyLeave.find(params[:id])
  end

  def approve_leave
    @applied_leave = ApplyLeave.find(params[:applied_leave])
    @applied_employee = Employee.find(@applied_leave.employee_id)
    @manager = @applied_employee.reporting_manager_id
    if @applied_leave.update_attributes( :approved => true, :viewed_by_manager => true, :manager_remark => params[:manager_remark])
      start_date = @applied_leave.start_date
      end_date = @applied_leave.end_date
      (start_date..end_date).each do |d|
      
        unless(d.strftime('%A') == "Sunday")
          EmployeeAttendance.create(:attendance_date=>d, :employee_id=>@applied_employee.id,:employee_leave_type_id=>@applied_leave.employee_leave_types_id, :reason => @applied_leave.reason, :is_half_day => @applied_leave.is_half_day)
          att = EmployeeAttendance.find_by_attendance_date(d)
          EmployeeAttendance.update(att.id, :is_half_day => @applied_leave.is_half_day)
          @reset_count = EmployeeLeave.find_by_employee_id(@applied_leave.employee_id, :conditions=> "employee_leave_type_id = '#{@applied_leave.employee_leave_types_id}'")
          leave_taken = @reset_count.leave_taken
          if @applied_leave.is_half_day
            leave_taken += 0.5
            @reset_count.update_attributes(:leave_taken=> leave_taken)
          else
            leave_taken += 1
            @reset_count.update_attributes(:leave_taken=> leave_taken)
          end
        end
      end
    end
    
        flash[:notice]="#{t('flash6')} #{@applied_employee.first_name} from #{@applied_leave.start_date} to #{@applied_leave.end_date}"
    redirect_to :controller=>"employee_attendance", :action=>"leaves", :id=>@manager
  end

  def deny_leave
    @applied_leave = ApplyLeave.find(params[:applied_leave])
    @applied_employee = Employee.find(@applied_leave.employee_id)
    @manager = @applied_employee.reporting_manager_id
    ApplyLeave.update(@applied_leave, :viewed_by_manager => true, :manager_remark =>params[:manager_remark])
        flash[:notice]="#{t('flash7')} #{@applied_employee.first_name} from #{@applied_leave.start_date} to #{@applied_leave.end_date}"
    redirect_to :action=>"leaves", :id=>@manager
  end

  def cancel
    render :text=>""
  end

  def new_leave_applications
    @employee = Employee.find(params[:id])
    @reporting_employees = Employee.find_all_by_reporting_manager_id(@employee.id)
    render :partial => "new_leave_applications"
  end

  def all_employee_new_leave_applications
    @employee = Employee.find(params[:id])
    @all_employees = Employee.find(:all)
    render :partial => "all_employee_new_leave_applications"
  end

  def all_leave_applications
    @employee = Employee.find(params[:id])
    @reporting_employees = Employee.find_all_by_reporting_manager_id(@employee.id)
    render :partial => "all_leave_applications"
  end

  def individual_leave_applications
    @employee = Employee.find(params[:id])
    @pending_applied_leaves = ApplyLeave.find_all_by_employee_id(@employee.id, :conditions=> "approved = false AND viewed_by_manager = false", :order=>"start_date DESC")
    @applied_leaves = ApplyLeave.paginate(:page => params[:page],:per_page=>10 , :conditions=>[ "employee_id = '#{@employee.id}'"], :order=>"start_date DESC")
    render :partial => "individual_leave_applications"
  end

  def own_leave_application
    @applied_leave = ApplyLeave.find(params[:id])
    @leave_type = EmployeeLeaveType.find(@applied_leave.employee_leave_types_id)
    @employee = Employee.find(@applied_leave.employee_id)
  end

  def cancel_application
    @applied_leave = ApplyLeave.find(params[:id])
    @employee = Employee.find(@applied_leave.employee_id)
    unless @applied_leave.viewed_by_manager
      ApplyLeave.destroy(params[:id])
        flash[:notice] = t('flash8')
    else
        flash[:notice] = t('flash10')
    end
    redirect_to :action=>"leaves", :id=>@employee.id
  end

  def update_all_application_view
    if params[:employee_id] == ""
      render :update do |page|
        page.replace_html "all-application-view", :text => ""
      end
      return
    end
    @employee = Employee.find(params[:employee_id])

    @all_pending_applied_leaves = ApplyLeave.find_all_by_employee_id(params[:employee_id], :conditions=> "approved = false AND viewed_by_manager = false", :order=>"start_date DESC")
    @all_applied_leaves = ApplyLeave.paginate(:page => params[:page], :per_page=>10, :conditions=> ["employee_id = '#{@employee.id}'"], :order=>"start_date DESC")
    render :update do |page|
      page.replace_html "all-application-view", :partial => "all_leave_application_lists"
    end
  end

  #PDF Methods

  def employee_attendance_pdf
    @employee = Employee.find(params[:id])
    @attendance_report = EmployeeAttendance.find_all_by_employee_id(@employee.id)
    @leave_types = EmployeeLeaveType.find(:all, :conditions => "status = true")
    @leave_count = EmployeeLeave.find_all_by_employee_id(@employee,:joins=>:employee_leave_type,:conditions=>"status = true")
    @total_leaves = 0
    @leave_types.each do |lt|
      leave_count = EmployeeAttendance.find_all_by_employee_id_and_employee_leave_type_id(@employee.id,lt.id).size
      @total_leaves = @total_leaves + leave_count
    end
    render :pdf => 'employee_attendance_pdf'
          

    #        respond_to do |format|
    #            format.pdf { render :layout => false }
    #        end
  end
end
