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
class EmployeeAttendanceController < ApplicationController
  before_filter :login_required, :configuration_settings_for_hr
  before_filter :protect_leave_dashboard, :only => [:leaves]
  before_filter :protect_applied_leave, :only => [:own_leave_application, :cancel_application]
  before_filter :protect_manager_leave_application_view, :only => [:leave_application]
  before_filter :protect_leave_history, :only => [:leave_history,:update_leave_history]

  filter_access_to :all

  def add_leave_types
    @leave_types = EmployeeLeaveType.all(:order => "name ASC", :conditions => {:status => true})
    @inactive_leave_types = EmployeeLeaveType.all(:order => "name ASC", :conditions => {:status => false})
    @leave_type = EmployeeLeaveType.new(params[:leave_type])
    @employee = Employee.all
    if request.post? && @leave_type.save
      @employee.each do |e|
        EmployeeLeave.create( :employee_id => e.id, :employee_leave_type_id => @leave_type.id, :leave_count => @leave_type.max_leave_count)
      end
      flash[:notice] = t('flash1')
      redirect_to :action => "add_leave_types"
    end
  end

  def edit_leave_types
    @leave_type = EmployeeLeaveType.find(params[:id])
    if request.post? && @leave_type.update_attributes(params[:leave_type])
      flash[:notice] = t('flash2')
      redirect_to :action => "add_leave_types"
    end
  end

  def delete_leave_types
    leave_type = EmployeeLeaveType.find(params[:id])
    attendance = EmployeeAttendance.find_all_by_employee_leave_type_id(leave_type.id)
    if attendance.blank?
      leave_count = EmployeeLeave.find_all_by_employee_leave_type_id(leave_type.id)
      leave_type.delete
      leave_count.each do |e|
        e.delete
      end
      flash[:notice] = t('flash3')
    else
      flash[:notice] = t('flash_msg12')
    end
    redirect_to :action => "add_leave_types"
  end

  def leave_reset_settings
    @auto_reset = Configuration.find_by_config_key('AutomaticLeaveReset')
    @reset_period = Configuration.find_by_config_key('LeaveResetPeriod')
    @last_reset = Configuration.find_by_config_key('LastAutoLeaveReset')
    @fin_start_date = Configuration.find_by_config_key('FinancialYearStartDate')
    if request.post?
      @auto_reset.update_attributes(:config_value => params[:configuration][:automatic_leave_reset])
      @reset_period.update_attributes(:config_value => params[:configuration][:leave_reset_period])
      @last_reset.update_attributes(:config_value => params[:configuration][:financial_year_start_date])
      flash[:notice] = t('flash_msg8')
    end
  end

  # I thinks this action should be a POST
  def update_employee_leave_reset_all
    EmployeeLeave.reset_all
    notice = t('leave_count_reset_sucessfull')
    render :update do |page|
      page.replace_html "main-reset-box", :text => "<p class='flash-msg'>#{notice}</p>"
    end
  end

  def employee_leave_reset_by_department
    @departments = EmployeeDepartment.all(:conditions => {:status => true}, :order => "name ASC")
  end

  def list_department_leave_reset
    @leave_types = EmployeeLeaveType.all(:conditions => {:status => true})
    if params[:department_id].blank?
      render :update do |page|
        page.replace_html "department-list", :text => ""
      end and return
    end
    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    render :update do |page|
      page.replace_html "department-list", :partial => 'department_list'
    end
  end

  def update_department_leave_reset
    leave_count = EmployeeLeave.all(conditions: ['employee_id IN (?)', params[:employee_id]])
    leave_count.each(&:reset)
    flash[:notice] = t('flash12')
    redirect_to :action => "employee_leave_reset_by_department"
  end

  def employee_leave_reset_by_employee
    @departments = EmployeeDepartment.all
    @categories  = EmployeeCategory.all
    @positions   = EmployeePosition.all
    @grades      = EmployeeGrade.all
  end

  def employee_search_ajax
    @employee = Employee.search_employees(params)
    render :layout => false
  end

  def employee_view_all
    @departments = EmployeeDepartment.all
  end

  def employees_list
    @employees = Employee.find_all_by_employee_department_id(params[:department_id],
                                                             :order=>'first_name ASC')

    render :update do |page|
      page.replace_html 'employee_list', :partial => 'employee_view_all_list', :object => @employees
    end
  end

  def employee_leave_details
    @employee = Employee.find_by_id(params[:id])
    @leave_count = EmployeeLeave.find_all_by_employee_id(params[:id])
  end

  def employee_wise_leave_reset
    @employee = Employee.find_by_id(params[:id])
    @leave_count = EmployeeLeave.find_all_by_employee_id(params[:id])
    @leave_count.each(&:reset)
    notice = t('flash_msg12')
    render :update do |page|
      flash.now[:notice] = notice
      page.replace_html "list", :partial => 'employee_reset_success'
    end
  end

  def register
    @departments = EmployeeDepartment.all(:conditions => {:status => true}, :order=> "name ASC")
    if request.post?
      if params[:employee_attendance]
        params[:employee_attendance].each_pair do |emp, att|
          EmployeeAttendance.create(:attendance_date => params[:date], reason: 'No reason',
                                    :employee_id => emp, :employee_leave_type_id => att) unless att == ""
        end
        flash[:notice] = t('flash3')
        redirect_to :action => "register"
      end
    end
  end

  def update_attendance_form
    @leave_types = EmployeeLeaveType.all(:conditions => {:status => true}, :order => "name ASC")
    if params[:department_id].blank?
      render :update do |page|
        page.replace_html "attendance_form", :text => ""
      end and return
    end

    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    render :update do |page|
      page.replace_html 'attendance_form', :partial => 'attendance_form'
    end
  end

  def report
    @departments = EmployeeDepartment.all(:conditions => {:status => true}, :order => "name ASC")
  end

  def update_attendance_report
    @leave_types = EmployeeLeaveType.all(:conditions => {:status => true})
    if params[:department_id].blank?
      render :update do |page|
        page.replace_html "attendance_report", :text => ""
      end and return
    end
    @employees = Employee.find_all_by_employee_department_id(params[:department_id])
    render :update do |page|
      page.replace_html "attendance_report", :partial => 'attendance_report'
    end
  end

  def emp_attendance
    @employee = Employee.find(params[:id])
    @attendance_report = EmployeeAttendance.find_all_by_employee_id(@employee.id)
    @leave_types = EmployeeLeaveType.all(:conditions => {:status => true})
    @leave_count = EmployeeLeave.find_all_by_employee_id(@employee.id,
                                                         joins: :employee_leave_type,
                                                         conditions: 'employee_leave_types.status IS TRUE')
    @total_leaves = @leave_types.inject(0) do |sum, lt|
      sum += EmployeeAttendance.find_all_by_employee_id_and_employee_leave_type_id(@employee.id, lt.id).size
    end
  end

  def leave_history
    @employee = Employee.find(params[:id])
  end

  def update_leave_history
    @employee = Employee.find(params[:id])
    @start_date = params[:period][:start_date]
    @end_date = params[:period][:end_date]
    @leave_types = EmployeeLeaveType.all(:conditions => {:status => true})
    @employee_attendances = Hash[@leave_types.map do |leave_type|
      [leave_type.name, EmployeeAttendance.all(conditions: {employee_id: @employee.id,
                                                            employee_leave_type_id: leave_type.id,
                                                            attendance_date: @start_date.to_date..@end_date.to_date})]
    end]
    render :update do |page|
      page.replace_html "attendance-report", :partial => 'update_leave_history'
    end
  end

  def leaves
    @leave_types = EmployeeLeaveType.all(:conditions => {:status => true})
    @employee = Employee.find(params[:id])
    @reporting_employees = Employee.find_all_by_reporting_manager_id(@employee.id)
    @total_leave_count = @reporting_employees.inject(0) do |sum, e|
      sum += ApplyLeave.count(:conditions => {:employee_id => e.id, :viewed_by_manager => false})
    end

    @leave_apply = ApplyLeave.new(params[:leave_apply])
    if request.post? && @leave_apply.save
      ApplyLeave.update(@leave_apply, :approved => false, :viewed_by_manager => false)
      flash[:notice] = t('flash5')
      redirect_to action: "leaves", id: @employee.id, controller: :employee_attendance
    end
  end

  def leave_application
    @applied_leave = ApplyLeave.find(params[:id])
    @applied_employee = Employee.find(@applied_leave.employee_id)
    @leave_type = EmployeeLeaveType.find(@applied_leave.employee_leave_type_id)
    @manager = @applied_employee.reporting_manager_id
    @leave_count = EmployeeLeave.find_by_employee_id_and_employee_leave_type_id(@applied_employee.id,
                                                                                @leave_type.id)
  end

  def leave_app
    @employee = Employee.find(params[:id2])
    @applied_leave = ApplyLeave.find(params[:id])
    @leave_type = EmployeeLeaveType.find(@applied_leave.employee_leave_type_id)
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
    applied_leave = ApplyLeave.find(params[:applied_leave])
    applied_employee = Employee.find(applied_leave.employee_id)
    manager = applied_employee.reporting_manager_id
    applied_leave.calculate_reset_count(params)

    flash[:notice] = "#{t('flash6')} #{applied_employee.first_name} from #{applied_leave.start_date} to #{applied_leave.end_date}"
    redirect_to :action => "leaves", :id => manager
  end

  def deny_leave
    applied_leave = ApplyLeave.find(params[:applied_leave])
    applied_employee = Employee.find(applied_leave.employee_id)
    manager = applied_employee.reporting_manager_id
    applied_leave.deny(params[:manager_remark])
    flash[:notice] = "#{t('flash7')} #{applied_employee.first_name} from #{applied_leave.start_date} to #{applied_leave.end_date}"
    redirect_to :action => "leaves", :id => manager
  end

  def cancel
    render :text => ""
  end

  def new_leave_applications
    @employee = Employee.find(params[:id])
    @reporting_employees = Employee.find_all_by_reporting_manager_id(@employee.id)
    render :partial => "new_leave_applications"
  end

  def all_employee_new_leave_applications
    @employee = Employee.find(params[:id])
    @all_employees = Employee.all
    render :partial => "all_employee_new_leave_applications"
  end

  def all_leave_applications
    @employee = Employee.find(params[:id])
    @reporting_employees = Employee.find_all_by_reporting_manager_id(@employee.id)
    render :partial => "all_leave_applications"
  end

  def individual_leave_applications
    @employee = Employee.find(params[:id])
    @pending_applied_leaves = ApplyLeave.find_all_by_employee_id(@employee.id,
                                                                 :conditions => {:approved => false, :viewed_by_manager => false},
                                                                 :order=>"start_date DESC")
    @applied_leaves = ApplyLeave.paginate(:page => params[:page],
                                          :per_page => 10 ,
                                          :conditions => {:employee_id => @employee.id},
                                          :order => "start_date DESC")
    render :partial => "individual_leave_applications"
  end

  def own_leave_application
    @applied_leave = ApplyLeave.find(params[:id])
    @leave_type = EmployeeLeaveType.find(@applied_leave.employee_leave_type_id)
    @employee = Employee.find(@applied_leave.employee_id)
  end

  def cancel_application
    applied_leave = ApplyLeave.find(params[:id])
    employee = Employee.find(applied_leave.employee_id)
    if applied_leave.viewed_by_manager
      flash[:notice] = t('flash10')
    else
      ApplyLeave.destroy(params[:id])
      flash[:notice] = t('flash8')
    end
    redirect_to :action => "leaves", :id => employee.id
  end

  def update_all_application_view
    if params[:employee_id] == ""
      render :update do |page|
        page.replace_html "all-application-view", :text => ""
      end and return
    end

    @employee = Employee.find(params[:employee_id])
    @all_pending_applied_leaves = ApplyLeave.all(conditions: {employee_id: @employee.id,
                                                              approved: false,
                                                              viewed_by_manager: false},
                                                 order: "start_date DESC")
    @all_applied_leaves = ApplyLeave.paginate(:page => params[:page],
                                              :per_page => 10,
                                              :conditions => {:employee_id => @employee.id},
                                              :order=>"start_date DESC")
    render :update do |page|
      page.replace_html "all-application-view", :partial => "all_leave_application_lists"
    end
  end

  #PDF Methods

  def employee_attendance_pdf
    @employee = Employee.find(params[:id])
    @attendance_report = EmployeeAttendance.find_all_by_employee_id(@employee.id)
    @leave_types = EmployeeLeaveType.all(:conditions => {:status => true})
    @leave_count = EmployeeLeave.all(:joins => :employee_leave_type,
                                     :conditions => ["employee_leave_types.status IS TRUE AND employee_id = ?", @employee.id])
    @total_leaves = @leave_types.inject(0) do |sum, lt|
      sum += EmployeeAttendance.find_all_by_employee_id_and_employee_leave_type_id(@employee.id,lt.id).size
    end
    render :pdf => 'employee_attendance_pdf'
  end
end
