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

class EmployeeController < ApplicationController
  before_filter :login_required,:configuration_settings_for_hr
  filter_access_to :all
  before_filter :protect_other_employee_data, :only => [:individual_payslip_pdf,:timetable,:timetable_pdf,:profile_payroll_details,\
      :view_payslip ]
  before_filter :limit_employee_profile_access , :only => [:profile,:profile_pdf]

  def add_category
    @categories = EmployeeCategory.find(:all,:order => "name asc",:conditions=>'status = 1')
    @inactive_categories = EmployeeCategory.find(:all,:conditions=>'status = 0')
    @category = EmployeeCategory.new(params[:category])
    if request.post? and @category.save
      flash[:notice] = t('flash1')
      redirect_to :controller => "employee", :action => "add_category"
    end
  end
  
  def edit_category
    @category = EmployeeCategory.find(params[:id])
    employees = Employee.find(:all ,:conditions=>"employee_category_id = #{params[:id]}")
    if request.post?
      if (params[:category][:status] == 'false' and employees.blank?) or params[:category][:status] == 'true'
        
        if @category.update_attributes(params[:category])
          unless @category.status
            position = EmployeePosition.find_all_by_employee_category_id(@category.id)
            position.each do |p|
              p.update_attributes(:status=> '0')
            end
          end
          flash[:notice] = t('flash2')
          redirect_to :action => "add_category"
        end
      else
        flash[:warn_notice] = "<p>#{t('flash2')}</p>"
      end
      
    end
  end

  def delete_category
    employees = Employee.find(:all ,:conditions=>"employee_category_id = #{params[:id]}")
    category_position = EmployeePosition.find(:all, :conditions=>"employee_category_id = #{params[:id]}")
    if employees.empty? and category_position.empty?
      EmployeeCategory.find(params[:id]).destroy
      @categories = EmployeeCategory.find :all
      flash[:notice]=t('flash3')
      redirect_to :action => "add_category"
    else
      flash[:notice]=t('flash4')
      redirect_to :action => "add_category"
    end
  end

  def add_position
    @positions = EmployeePosition.find(:all,:order => "name asc",:conditions=>'status = 1')
    @inactive_positions = EmployeePosition.find(:all,:order => "name asc",:conditions=>'status = 0')
    @categories = EmployeeCategory.find(:all,:order => "name asc",:conditions=> 'status = 1')
    @position = EmployeePosition.new(params[:position])
    if request.post? and @position.save
      flash[:notice] = t('flash5')
      redirect_to :controller => "employee", :action => "add_position"
    end
  end

  def edit_position
    @categories = EmployeeCategory.find(:all)
    @position = EmployeePosition.find(params[:id])
    employees = Employee.find(:all ,:conditions=>"employee_position_id = #{params[:id]}")
    if request.post?
      if (params[:position][:status] == 'false' and employees.blank?) or params[:position][:status] == 'true'
        if @position.update_attributes(params[:position])
          flash[:notice] = t('flash6')
          redirect_to :action => "add_position"
        end
      end
      flash[:warn_notice] = "<p>#{t('flash38')}</p>"
    end

  end

  def delete_position
    employees = Employee.find(:all ,:conditions=>"employee_position_id = #{params[:id]}")

    if employees.empty?
      EmployeePosition.find(params[:id]).destroy
      @positions = EmployeePosition.find :all
      flash[:notice]=t('flash3')
      redirect_to :action => "add_position"
    else
      flash[:notice]=t('flash4')
      redirect_to :action => "add_position"
    end
  end

  def add_department
    @departments = EmployeeDepartment.find(:all,:order => "name asc",:conditions=>'status = 1')
    @inactive_departments = EmployeeDepartment.find(:all,:order => "name asc",:conditions=>'status = 0')
    @department = EmployeeDepartment.new(params[:department])
    if request.post? and @department.save
      flash[:notice] =  t('flash7')
      redirect_to :controller => "employee", :action => "add_department"
    end
  end

  def edit_department
    @department = EmployeeDepartment.find(params[:id])
    employees = Employee.find(:all ,:conditions=>"employee_department_id = #{params[:id]}")
    if request.post?
      if (params[:department][:status] == 'false' and employees.blank?) or params[:department][:status] == 'true'
        if @department.update_attributes(params[:department])
          flash[:notice] = t('flash8')
          redirect_to :action => "add_department"
        end
      end
      flash[:warn_notice] = "<p>#{t('flash39')}</p>"
    end
  end

  def delete_department
    employees = Employee.find(:all ,:conditions=>"employee_department_id = #{params[:id]}")
    if employees.empty?
      EmployeeDepartment.find(params[:id]).destroy
      @departments = EmployeeDepartment.find :all
      flash[:notice]=t('flash3')
      redirect_to :action => "add_department"
    else
      flash[:notice]=t('flash4')
      redirect_to :action => "add_department"
    end
  end

  def add_grade
    @grades = EmployeeGrade.find(:all,:order => "name asc",:conditions=>'status = 1')
    @inactive_grades = EmployeeGrade.find(:all,:order => "name asc",:conditions=>'status = 0')
    @grade = EmployeeGrade.new(params[:grade])
    if request.post? and @grade.save
      flash[:notice] =  t('flash9')
      redirect_to :controller => "employee", :action => "add_grade"
    end
  end

  def edit_grade
    @grade = EmployeeGrade.find(params[:id])
    employees = Employee.find(:all ,:conditions=>"employee_grade_id = #{params[:id]}")
    if request.post?
      if (params[:grade][:status] == 'false' and employees.blank?) or params[:grade][:status] == 'true'
        if @grade.update_attributes(params[:grade])
          flash[:notice] = t('flash10')
          redirect_to :action => "add_grade"
        end
      end
      flash[:warn_notice] = "<p>#{t('flash40')}</p>"
    end
  end

  def delete_grade
    employees = Employee.find(:all ,:conditions=>"employee_grade_id = #{params[:id]}")
    if employees.empty?
      EmployeeGrade.find(params[:id]).destroy
      @grades = EmployeeGrade.find :all
      flash[:notice]=t('flash3')
      redirect_to :action => "add_grade"
    else
      flash[:notice]=t('flash4')
      redirect_to :action => "add_grade"
    end
  end

  def add_bank_details
    @bank_details = BankField.find(:all,:order => "name asc",:conditions=>{:status => true})
    @inactive_bank_details = BankField.find(:all,:order => "name asc",:conditions=>{:status => false})
    @bank_field = BankField.new(params[:bank_field])
    if request.post? and @bank_field.save
      flash[:notice] =t('flash11')
      redirect_to :controller => "employee", :action => "add_bank_details"
    end
  end

  def edit_bank_details
    @bank_details = BankField.find(params[:id])
    if request.post? and @bank_details.update_attributes(params[:bank_details])
      flash[:notice] = t('flash12')
      redirect_to :action => "add_bank_details"
    end
  end
  def delete_bank_details
    employees = EmployeeBankDetail.find(:all ,:conditions=>"bank_field_id = #{params[:id]}")
    if employees.empty?
      BankField.find(params[:id]).destroy
      @bank_details = BankField.find(:all)
      flash[:notice]=t('flash3')
      redirect_to :action => "add_bank_details"
    else
      flash[:notice]=t('flash4')
      redirect_to :action => "add_bank_details"
    end
  end

  def add_additional_details
    @additional_details = AdditionalField.find(:all,:order => "name asc",:conditions=>'status = 1')
    @inactive_additional_details = AdditionalField.find(:all,:order => "name asc",:conditions=>'status = 0')
    @additional_field = AdditionalField.new(params[:additional_field])
    if request.post? and @additional_field.save
      flash[:notice] = t('flash13')
      redirect_to :controller => "employee", :action => "add_additional_details"
    end
  end

  def edit_additional_details
    @additional_details = AdditionalField.find(params[:id])
    if request.post? and @additional_details.update_attributes(params[:additional_details])
      flash[:notice] = t('flash14')
      redirect_to :action => "add_additional_details"
    end
  end
  def delete_additional_details
    if params[:id]
      employees = EmployeeAdditionalDetail.find(:all ,:conditions=>"additional_field_id = #{params[:id]}")
      if employees.empty?
        AdditionalField.find(params[:id]).destroy
        @additional_details = AdditionalField.find(:all)
        flash[:notice]=t('flash3')
        redirect_to :action => "add_additional_details"
      else
        flash[:notice]=t('flash4')
        redirect_to :action => "add_additional_details"
      end
    else
      redirect_to :action => "add_additional_details"
    end
  end

  def admission1
    @user = current_user
    @user_name = @user.username
    @employee1 = @user.employee_record
    @categories = EmployeeCategory.find(:all,:order => "name asc",:conditions => "status = true")
    @positions = []
    @grades = EmployeeGrade.find(:all,:order => "name asc",:conditions => "status = true")
    @departments = EmployeeDepartment.find(:all,:order => "name asc",:conditions => "status = true")
    @nationalities = Country.all
    @employee = Employee.new(params[:employee])
    @selected_value = Configuration.default_country
    @last_admitted_employee = Employee.find(:last,:conditions=>"employee_number != 'admin'")
    @config = Configuration.find_by_config_key('EmployeeNumberAutoIncrement')

    if request.post?

      unless params[:employee][:employee_number].to_i ==0
        @employee.employee_number= "E" + params[:employee][:employee_number].to_s
      end
      unless @employee.employee_number.to_s.downcase == 'admin'
        if @employee.save
          if params[:employee][:gender] == "true"
            Employee.update(@employee.id, :gender => true)
          else
            Employee.update(@employee.id, :gender => false)
          end

          if params[:employee][:status] == "true"
            Employee.update(@employee.id, :status => true)
          else
            Employee.update(@employee.id, :status => false)
          end


          @leave_type = EmployeeLeaveType.all
          @leave_type.each do |e|
            EmployeeLeave.create( :employee_id => @employee.id, :employee_leave_type_id => e.id, :leave_count => e.max_leave_count)
          end
          flash[:notice] = "#{t('flash15')} #{@employee.first_name} #{t('flash16')}"
          redirect_to :controller =>"employee" ,:action => "admission2", :id => @employee.id
        end
      else
        @employee.errors.add(:employee_number, "#{t('should_not_be_admin')}")
      end
      @positions = EmployeePosition.find_all_by_employee_category_id(params[:employee][:employee_category_id])
    end
  end

  def update_positions
    category = EmployeeCategory.find(params[:category_id])
    @positions = EmployeePosition.find_all_by_employee_category_id(category.id,:conditions=>'status = 1')
    render :update do |page|
      page.replace_html 'positions1', :partial => 'positions', :object => @positions
    end
  end

  def edit1
    @categories = EmployeeCategory.find(:all,:order => "name asc", :conditions => "status = true")
    @positions = EmployeePosition.find(:all)
    @grades = EmployeeGrade.find(:all,:order => "name asc", :conditions => "status = true")
    @departments = EmployeeDepartment.find(:all,:order => "name asc", :conditions => "status = true")
    @employee = Employee.find(params[:id])
    @employee_user = @employee.user
    if request.post?
      if  params[:employee][:employee_number].downcase != 'admin' or @employee_user.admin
        if @employee.update_attributes(params[:employee])
          if params[:employee][:gender] == "true"
            Employee.update(@employee.id, :gender => true)
          else
            Employee.update(@employee.id, :gender => false)
          end

          if params[:employee][:status] == "true"
            Employee.update(@employee.id, :status => true)
          else
            Employee.update(@employee.id, :status => false)
          end

          flash[:notice] = "#{t('flash15')}  #{@employee.first_name} #{t('flash17')}"
          redirect_to :controller =>"employee" ,:action => "profile", :id => @employee.id
        end
      else
        @employee.errors.add(:employee_number, "#{t('should_not_be_admin')}")
      end
    end
  end

  def edit_personal
    @nationalities = Country.all
    @employee = Employee.find(params[:id])
    if request.post?
      size = 0
      size =  params[:employee][:image_file].size.to_f unless  params[:employee][:image_file].nil?
      if size < 280000
        if @employee.update_attributes(params[:employee])
          flash[:notice] = "#{t('flash15')}  #{@employee.first_name} #{t('flash18')}"
          redirect_to :controller =>"employee" ,:action => "profile", :id => @employee.id
        end
      else
        flash[:notice] = t('flash19')
        redirect_to :controller => "employee", :action => "edit_personal", :id => @employee.id
      end
    end
  end

  def admission2
    @countries = Country.find(:all)
    @employee = Employee.find(params[:id])
    @selected_value = Configuration.default_country
    if request.post? and @employee.update_attributes(params[:employee])
      sms_setting = SmsSetting.new()
      if sms_setting.application_sms_active and sms_setting.employee_sms_active
        recipient = ["#{@employee.mobile_phone}"]
        message = "#{t('joining_info')} #{@employee.first_name}. #{t('username')}: #{@employee.employee_number}, #{t('password')}: #{@employee.employee_number}123. #{t('change_password_after_login')}"
        Delayed::Job.enqueue(SmsManager.new(message,recipient))
      end
      flash[:notice] = "#{t('flash20')} #{ @employee.first_name}"
      redirect_to :action => "admission3", :id => @employee.id
    end
  end
  
  def edit2
    @employee = Employee.find(params[:id])
    @countries = Country.find(:all)
    if request.post? and @employee.update_attributes(params[:employee])
      flash[:notice] = "#{t('flash21')} #{ @employee.first_name}"
      redirect_to :action => "profile", :id => @employee.id
    end
  end

  def edit_contact
    @employee = Employee.find(params[:id])
    if request.post? and @employee.update_attributes(params[:employee])
      User.update(@employee.user.id, :email=> @employee.email, :role=>@employee.user.role_name)
      flash[:notice] = "#{t('flash22')} #{ @employee.first_name}"
      redirect_to :action => "profile", :id => @employee.id
    end
  end


  def admission3
    @employee = Employee.find(params[:id])
    @bank_fields = BankField.find(:all, :conditions=>"status = true")
    if @bank_fields.empty?
      redirect_to :action => "admission3_1", :id => @employee.id
    end
    if request.post?
      params[:employee_bank_details].each_pair do |k, v|
        EmployeeBankDetail.create(:employee_id => params[:id],
          :bank_field_id => k,:bank_info => v['bank_info'])
      end
      flash[:notice] = "#{t('flash23')} #{@employee.first_name}"
      redirect_to :action => "admission3_1", :id => @employee.id
    end
  end
  
  def edit3
    @employee = Employee.find(params[:id])
    @bank_fields = BankField.find(:all, :conditions=>"status = true")
    if @bank_fields.empty?
      flash[:notice] = "#{t('flash36')}"
      redirect_to :action => "profile", :id => @employee.id
    end
    if request.post?
      params[:employee_bank_details].each_pair do |k, v|
        row_id= EmployeeBankDetail.find_by_employee_id_and_bank_field_id(@employee.id,k)
        unless row_id.nil?
          bank_detail = EmployeeBankDetail.find_by_employee_id_and_bank_field_id(@employee.id,k)
          EmployeeBankDetail.update(bank_detail.id,:bank_info => v['bank_info'])
        else
          EmployeeBankDetail.create(:employee_id=>@employee.id,:bank_field_id=>k,:bank_info=>v['bank_info'])
        end
      end
      flash[:notice] = "#{t('flash15')}#{@employee.first_name} #{t('flash12')}"
      redirect_to :action => "profile", :id => @employee.id
    end
  end

  def admission3_1
    @employee = Employee.find(params[:id])
    @additional_fields = AdditionalField.find(:all, :conditions=>"status = true")
    if @additional_fields.empty?
      redirect_to :action => "edit_privilege", :id => @employee.employee_number
    end
    if request.post?
      params[:employee_additional_details].each_pair do |k, v|
        EmployeeAdditionalDetail.create(:employee_id => params[:id],
          :additional_field_id => k,:additional_info => v['additional_info'])
      end
      flash[:notice] = "#{t('flash25')}#{@employee.first_name}"
      redirect_to :action => "edit_privilege", :id => @employee.employee_number
    end
  end

  def edit_privilege
    @privileges = Privilege.find(:all)
    @user = User.find_by_username(params[:id])
    @employee = @user.employee_record
    if request.post?
      new_privileges = params[:user][:privilege_ids] if params[:user]
      new_privileges ||= []
      @user.privileges = Privilege.find_all_by_id(new_privileges)
      redirect_to :action => 'admission4',:id => @employee.id
    end
  end

  def edit3_1
    @employee = Employee.find(params[:id])
    @additional_fields = AdditionalField.find(:all, :conditions=>"status = true")
    if @additional_fields.empty?
      flash[:notice] = "#{t('flash37')}"
      redirect_to :action => "profile", :id => @employee.id
    end
    if request.post?
      params[:employee_additional_details].each_pair do |k, v|
        row_id= EmployeeAdditionalDetail.find_by_employee_id_and_additional_field_id(@employee.id,k)
        unless row_id.nil?
          additional_detail = EmployeeAdditionalDetail.find_by_employee_id_and_additional_field_id(@employee.id,k)
          EmployeeAdditionalDetail.update(additional_detail.id,:additional_info => v['additional_info'])
        else
          EmployeeAdditionalDetail.create(:employee_id=>@employee.id,:additional_field_id=>k,:additional_info=>v['additional_info'])
        end
      end
      flash[:notice] = "#{t('flash15')}#{@employee.first_name} #{t('flash14')}"
      redirect_to :action => "profile", :id => @employee.id
    end
  end

  def admission4
    @departments = EmployeeDepartment.find(:all)
    @categories  = EmployeeCategory.find(:all)
    @positions   = EmployeePosition.find(:all)
    @grades      = EmployeeGrade.find(:all)
    if request.post?
      @employee = Employee.find(params[:id])
      Employee.update(@employee, :reporting_manager_id => params[:employee][:reporting_manager_id])
      flash[:notice]=t('flash25')
      redirect_to :controller => "payroll", :action => "manage_payroll", :id=>@employee.id
    end
  
  end

  def view_rep_manager
    @employee= Employee.find(params[:id])
    @reporting_manager = Employee.find(@employee.reporting_manager_id).first_name unless @employee.reporting_manager_id.nil?
    render :partial => "view_rep_manager"
  end

  def change_reporting_manager
    @departments = EmployeeDepartment.find(:all)
    @categories  = EmployeeCategory.find(:all)
    @positions   = EmployeePosition.find(:all)
    @grades      = EmployeeGrade.find(:all)
    @emp = Employee.find(params[:id])
    @reporting_manager = Employee.find(@emp.reporting_manager_id).first_name unless @emp.reporting_manager_id.nil?
    if request.post?
      @employee = Employee.find(params[:id])
      Employee.update(@employee, :reporting_manager_id => params[:employee][:reporting_manager_id])
      flash[:notice]=t('flash26')
      redirect_to :action => "profile", :id=>@employee.id
    end
  end

  def update_reporting_manager_name
    employee = Employee.find(params[:employee_reporting_manager_id])
    render :text => employee.first_name + ' ' + employee.last_name
  end

  def search
    @departments = EmployeeDepartment.all
    @categories  = EmployeeCategory.all
    @positions   = EmployeePosition.all
    @grades      = EmployeeGrade.all
  end

  def search_ajax
    other_conditions = ""
    other_conditions += " AND employee_department_id = '#{params[:employee_department_id]}'" unless params[:employee_department_id] == ""
    other_conditions += " AND employee_category_id = '#{params[:employee_category_id]}'" unless params[:employee_category_id] == ""
    other_conditions += " AND employee_position_id = '#{params[:employee_position_id]}'" unless params[:employee_position_id] == ""
    other_conditions += " AND employee_grade_id = '#{params[:employee_grade_id]}'" unless params[:employee_grade_id] == ""
    if params[:query].length>= 3
      @employee = Employee.find(:all,
        :conditions => ["(first_name LIKE ? OR middle_name LIKE ? OR last_name LIKE ?
                       OR employee_number = ? OR (concat(first_name, \" \", last_name) LIKE ? ))"+ other_conditions,
          "#{params[:query]}%","#{params[:query]}%","#{params[:query]}%",
          "#{params[:query]}", "#{params[:query]}" ],
        :order => "employee_department_id asc,first_name asc",:include=>"employee_department") unless params[:query] == ''
    else
      @employee = Employee.find(:all,
        :conditions => ["(employee_number = ? )"+ other_conditions, "#{params[:query]}"],
        :order => "employee_department_id asc,first_name asc",:include=>"employee_department") unless params[:query] == ''
    end
    render :layout => false
  end

  def select_reporting_manager
    other_conditions = ""
    other_conditions += " AND employee_department_id = '#{params[:employee_department_id]}'" unless params[:employee_department_id] == ""
    other_conditions += " AND employee_category_id = '#{params[:employee_category_id]}'" unless params[:employee_category_id] == ""
    other_conditions += " AND employee_position_id = '#{params[:employee_position_id]}'" unless params[:employee_position_id] == ""
    other_conditions += " AND employee_grade_id = '#{params[:employee_grade_id]}'" unless params[:employee_grade_id] == ""
    if params[:query].length>= 3
      @employee = Employee.find(:all,
        :conditions => ["(first_name LIKE ? OR middle_name LIKE ? OR last_name LIKE ?
                       OR employee_number = ? OR (concat(first_name, \" \", last_name) LIKE ? ))"+ other_conditions,
          "#{params[:query]}%","#{params[:query]}%","#{params[:query]}%",
          "#{params[:query]}", "#{params[:query]}" ],
        :order => "employee_department_id asc,first_name asc") unless params[:query] == ''
    else
      @employee = Employee.find(:all,
        :conditions => ["employee_number = ? "+ other_conditions, "#{params[:query]}%"],
        :order => "employee_department_id asc,first_name asc") unless params[:query] == ''
    end
    render :layout => false
  end

  def profile

    @current_user = current_user
    @employee = Employee.find(params[:id])
    @new_reminder_count = Reminder.find_all_by_recipient(@current_user.id, :conditions=>"is_read = false")
    @gender = "Male"
    @gender = "Female" if @employee.gender == false
    @status = "Active"
    @status = "Inactive" if @employee.status == false
    @reporting_manager = Employee.find(@employee.reporting_manager_id).full_name unless @employee.reporting_manager_id.nil?
    exp_years = @employee.experience_year
    exp_months = @employee.experience_month
    date = Date.today
    total_current_exp_days = (date-@employee.joining_date).to_i
    current_years = (total_current_exp_days/365)
    rem = total_current_exp_days%365
    current_months = rem/30
    #year = exp_years+current_years unless exp_years.nil?
    #month = exp_months+current_months unless exp_months.nil?
    total_month = (exp_months || 0)+current_months
    year = total_month/12
    month = total_month%12
    @total_years = (exp_years || 0)+current_years+year
    @total_months = month

  end

  def profile_general
    @employee = Employee.find(params[:id])
    @gender = "Male"
    @gender = "Female" if @employee.gender == false
    @status = "Active"
    @status = "Inactive" if @employee.status == false
    @reporting_manager = Employee.find(@employee.reporting_manager_id).first_name unless @employee.reporting_manager_id.nil?
    exp_years = @employee.experience_year
    exp_months = @employee.experience_month
    date = Date.today
    total_current_exp_days = (date-@employee.joining_date).to_i
    current_years = (total_current_exp_days/365)
    rem = total_current_exp_days%365
    current_months = rem/30
    #year = exp_years+current_years unless exp_years.nil?
    #month = exp_months+current_months unless exp_months.nil?
    total_month = (exp_months || 0)+current_months
    year = total_month/12
    month = total_month%12
    @total_years = (exp_years || 0 )+current_years+year
    @total_months = month
    render :partial => "general"
  end

  def profile_personal
    @employee = Employee.find(params[:id])
    render :partial => "personal"
  end

  def profile_address
    @employee = Employee.find(params[:id])
    @home_country = Country.find(@employee.home_country_id).name unless @employee.home_country_id.nil?
    @office_country = Country.find(@employee.office_country_id).name unless @employee.office_country_id.nil?
    render :partial => "address"
  end

  def profile_contact
    @employee = Employee.find(params[:id])
    render :partial => "contact"
  end

  def profile_bank_details
    @employee = Employee.find(params[:id])
    @bank_details = EmployeeBankDetail.find_all_by_employee_id(@employee.id)
    render :partial => "bank_details"
  end

  def profile_additional_details
    @employee = Employee.find(params[:id])
    @additional_details = EmployeeAdditionalDetail.find_all_by_employee_id(@employee.id)
    render :partial => "additional_details"
  end


  def profile_payroll_details
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    @employee = Employee.find(params[:id])
    @payroll_details = EmployeeSalaryStructure.find_all_by_employee_id(@employee, :order=>"payroll_category_id ASC")
    render :partial => "payroll_details"
  end

  def profile_pdf
    @employee = Employee.find(params[:id])
    @gender = "Male"
    @gender = "Female" if @employee.gender == false
    @status = "Active"
    @status = "Inactive" if @employee.status == false
    @reporting_manager = Employee.find(@employee.reporting_manager_id).first_name unless @employee.reporting_manager_id.nil?
    exp_years = @employee.experience_year
    exp_months = @employee.experience_month
    date = Date.today
    total_current_exp_days = (date-@employee.joining_date).to_i
    current_years = total_current_exp_days/365
    rem = total_current_exp_days%365
    current_months = rem/30
    total_month = current_months if exp_months.nil?
    total_month = exp_months+current_months unless exp_months.nil?
    year = total_month/12
    month = total_month%12
    @total_years = current_years+year if exp_years.nil?
    @total_years = exp_years+current_years+year unless exp_years.nil?
    @total_months = month
    @home_country = Country.find(@employee.home_country_id).name unless @employee.home_country_id.nil?
    @office_country = Country.find(@employee.office_country_id).name unless @employee.office_country_id.nil?
    @bank_details = EmployeeBankDetail.find_all_by_employee_id(@employee.id)
    @additional_details = EmployeeAdditionalDetail.find_all_by_employee_id(@employee.id)
    render :pdf => 'profile_pdf'
          
            
    #    respond_to do |format|
    #      format.pdf { render :layout => false }
    #    end
  end

  def view_all
    @departments = EmployeeDepartment.active
  end

  def employees_list
    department_id = params[:department_id]
    @employees = Employee.find_all_by_employee_department_id(department_id,:order=>'first_name ASC')

    render :update do |page|
      page.replace_html 'employee_list', :partial => 'employee_view_all_list', :object => @employees
    end
  end

  def show
    @employee = Employee.find(params[:id])
    send_data(@employee.photo_data, :type => @employee.photo_content_type, :filename => @employee.photo_filename, :disposition => 'inline')
  end

  def add_payslip_category
    @employee = Employee.find(params[:emp_id])
    @salary_date = (params[:salary_date])
    render :partial => "payslip_category_form"
  end

  def create_payslip_category
    @employee=Employee.find(params[:employee_id])
    @salary_date= (params[:salary_date])
    @created_category = IndividualPayslipCategory.new(:employee_id=>params[:employee_id],:name=>params[:name],:amount=>params[:amount])
    if @created_category.save
      if params[:is_deduction] == nil
        IndividualPayslipCategory.update(@created_category.id, :is_deduction=>false)
      else
        IndividualPayslipCategory.update(@created_category.id, :is_deduction=>params[:is_deduction])
      end

      if params[:include_every_month] == nil
        IndividualPayslipCategory.update(@created_category.id, :include_every_month=>false)
      else
        IndividualPayslipCategory.update(@created_category.id, :include_every_month=>params[:include_every_month])
      end

      @new_payslip_category = IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(@employee.id,nil)
      @individual = IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(@employee.id,@salary_date)
      render :partial => "payslip_category_list",:locals => {:emp_id => @employee.id, :salary_date=>@salary_date}
    else
      render :partial => "payslip_category_form"
    end
  end

  def remove_new_paylist_category
    removal_category = IndividualPayslipCategory.find(params[:id])
    employee = removal_category.employee_id
    @salary_date = params[:id3]
    removal_category.destroy
    @new_payslip_category = IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(employee,nil)
    @individual = IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(employee,@salary_date, :conditions=>"") unless params[:id3]==''
    @individual ||= []
    render :partial => "list_payslip_category"
  end

  def create_monthly_payslip
    @new_payslip_category == []
    @salary_date = ''
    @employee = Employee.find(params[:id])
    @independent_categories = PayrollCategory.find_all_by_payroll_category_id_and_status(nil, true)
    @dependent_categories = PayrollCategory.find_all_by_status(true, :conditions=>"payroll_category_id != \'\'")
    @employee_additional_categories = IndividualPayslipCategory.find_all_by_employee_id(@employee.id, :conditions=>"include_every_month = true")
    @new_payslip_category = IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(@employee.id,nil)
    @individual = IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(@employee.id,Date.today)
    @user = current_user
    if request.post?
      salary_date = Date.parse(params[:salary_date])
      unless salary_date.to_date < @employee.joining_date.to_date
        start_date = salary_date - ((salary_date.day - 1).days)
        end_date = start_date + 1.month
        payslip_exists = MonthlyPayslip.find_all_by_employee_id(@employee.id,
          :conditions => ["salary_date >= ? and salary_date < ?", start_date, end_date])
        if payslip_exists == []
          params[:manage_payroll].each_pair do |k, v|
            row_id = EmployeeSalaryStructure.find_by_employee_id_and_payroll_category_id(@employee, k)
            category_name = PayrollCategory.find(k).name
            unless row_id.nil?
              MonthlyPayslip.create(:salary_date=>start_date,:employee_id => params[:id],
                :payroll_category_id => k,:amount => v['amount'])
            else
              MonthlyPayslip.create(:salary_date=>start_date,:employee_id => params[:id],
                :payroll_category_id => k,:amount => v['amount'])
            end
          end
          individual_payslip_category = IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(@employee.id,nil)
          individual_payslip_category.each do |c|
            IndividualPayslipCategory.update(c.id, :salary_date=>start_date)
          end
          flash[:notice] = "#{@employee.first_name} #{t('flash27')} #{params[:salary_date]}"
        else #else for if payslip_exists == []
          individual_payslips_generated = IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(@employee.id,nil)
          unless individual_payslips_generated.nil?
            individual_payslips_generated.each do|i|
              i.delete
            end
          end
          flash[:notice] = "#{@employee.first_name} #{t('flash28')} #{params[:salary_date]}"
        end
        privilege = Privilege.find_by_name("FinanceControl")
        finance_manager_ids = privilege.user_ids
        subject = t('payslip_generated')
        body = "#{t('payslip_generated_for')}  "+@employee.first_name+" "+@employee.last_name+". #{t('kindly_approve')}"
        Delayed::Job.enqueue(DelayedReminderJob.new( :sender_id  => @user.id,
            :recipient_ids => finance_manager_ids,
            :subject=>subject,
            :body=>body ))
        redirect_to :controller => "employee", :action => "select_department_employee"
      else
        flash[:warn_notice] = "#{t('flash45')} #{params[:salary_date]}"
      end
    end
    
  end

  def view_payslip
    @employee = Employee.find(params[:id])
    @salary_dates = MonthlyPayslip.find_all_by_employee_id(params[:id], :conditions=>"is_approved = true",:select => "distinct salary_date")
    render :partial => "select_dates"
  end

  def update_monthly_payslip
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    @salary_date = params[:salary_date]
    if params[:salary_date] == ""
      render :update do |page|
        page.replace_html "payslip_view", :text => ""
      end
      return
    end
    @monthly_payslips = MonthlyPayslip.find_all_by_salary_date(params[:salary_date],
      :conditions=> "employee_id =#{params[:emp_id]}",
      :order=> "payroll_category_id ASC")

    @individual_payslip_category = IndividualPayslipCategory.find_all_by_salary_date(params[:salary_date],
      :conditions=>"employee_id =#{params[:emp_id]}",
      :order=>"id ASC")
    @individual_category_non_deductionable = 0
    @individual_category_deductionable = 0
    @individual_payslip_category.each do |pc|
      unless pc.is_deduction == true
        @individual_category_non_deductionable = @individual_category_non_deductionable + pc.amount.to_i
      end
    end

    @individual_payslip_category.each do |pc|
      unless pc.is_deduction == false
        @individual_category_deductionable = @individual_category_deductionable + pc.amount.to_i
      end
    end

    @non_deductionable_amount = 0
    @deductionable_amount = 0
    @monthly_payslips.each do |mp|
      category1 = PayrollCategory.find(mp.payroll_category_id)
      unless category1.is_deduction == true
        @non_deductionable_amount = @non_deductionable_amount + mp.amount.to_i
      end
    end

    @monthly_payslips.each do |mp|
      category2 = PayrollCategory.find(mp.payroll_category_id)
      unless category2.is_deduction == false
        @deductionable_amount = @deductionable_amount + mp.amount.to_i
      end
    end

    @net_non_deductionable_amount = @individual_category_non_deductionable + @non_deductionable_amount
    @net_deductionable_amount = @individual_category_deductionable + @deductionable_amount

    @net_amount = @net_non_deductionable_amount - @net_deductionable_amount
    render :update do |page|
      page.replace_html "payslip_view", :partial => "view_payslip"
    end
  end

  def delete_payslip
    @individual_payslip_category=IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(params[:id],params[:id2])
    @individual_payslip_category.each do |pc|
      pc.destroy
    end
    @monthly_payslip = MonthlyPayslip.find_all_by_employee_id_and_salary_date(params[:id], params[:id2])
    @monthly_payslip.each do |m|
      m.destroy
    end
    flash[:notice]= "#{t('flash30')} #{params[:id2]}"
    redirect_to :controller=>"employee", :action=>"profile", :id=>params[:id]
  end

  def view_attendance
    @employee = Employee.find(params[:id])
    @attendance_report = EmployeeAttendance.find_all_by_employee_id(@employee.id)
    @leave_types = EmployeeLeaveType.find(:all, :conditions => "status = true")
    @leave_count = EmployeeLeave.find_all_by_employee_id(@employee,:joins=>:employee_leave_type,:conditions=>"status = true")
    @total_leaves = 0
    @leave_types.each do |lt|
      leave_count = EmployeeAttendance.find_all_by_employee_id_and_employee_leave_type_id(@employee.id,lt.id).size
      @total_leaves = @total_leaves + leave_count
    end
    render :partial => "attendance_report"
  end

  def employee_leave_count_edit
    @leave_count = EmployeeLeave.find_by_id(params[:id])
    @leave_type = EmployeeLeaveType.find_by_id(params[:leave_type])

    render :update do |page|
      page.replace_html 'profile-infos', :partial => 'edit_leave_count'
    end
  end

  def employee_leave_count_update
    available_leave = params[:leave_count][:leave_count]
    leave = EmployeeLeave.find_by_id(params[:id])
    leave.update_attributes(:leave_count => available_leave.to_f)
    @employee = Employee.find(leave.employee_id)
    @attendance_report = EmployeeAttendance.find_all_by_employee_id(@employee.id)
    @leave_types = EmployeeLeaveType.find(:all, :conditions => "status = true")
    @leave_count = EmployeeLeave.find_all_by_employee_id(@employee)
    @total_leaves = 0
    @leave_types.each do |lt|
      leave_count = EmployeeAttendance.find_all_by_employee_id_and_employee_leave_type_id(@employee.id,lt.id).size
      @total_leaves = @total_leaves + leave_count
    end
    render :update do |page|
      page.replace_html 'profile-infos',:partial => "attendance_report"
    end
  end

  def subject_assignment
    @batches = Batch.active
    @subjects = []
  end

  def update_subjects
    batch = Batch.find(params[:batch_id])
    @subjects = Subject.find_all_by_batch_id(batch.id,:conditions=>"is_deleted=false")

    render :update do |page|
      page.replace_html 'subjects1', :partial => 'subjects', :object => @subjects
    end
  end

  def select_department
    @subject = Subject.find(params[:subject_id])
    @assigned_employee = EmployeesSubject.find_all_by_subject_id(@subject.id)
    @departments = EmployeeDepartment.find(:all, :conditions =>{:status=>true})
    render :update do |page|
      page.replace_html 'department-select', :partial => 'select_department'
    end
  end

  def update_employees
    @subject = Subject.find(params[:subject_id])
    @employees = Employee.find_all_by_employee_department_id(params[:department_id], :conditions =>{:status=>true})
    render :update do |page|
      page.replace_html 'employee-list', :partial => 'employee_list'
    end
  end

  def assign_employee
    @departments = EmployeeDepartment.find(:all,:conditions =>{:status=>true})
    @subject = Subject.find(params[:id1])
    @employees = Employee.find_all_by_employee_department_id(Employee.find(params[:id]).employee_department_id)
    EmployeesSubject.create(:employee_id => params[:id], :subject_id => params[:id1])
    @assigned_employee = EmployeesSubject.find_all_by_subject_id(@subject.id)
    render :partial =>"select_department"
  end

  def remove_employee
    @departments = EmployeeDepartment.find(:all,:conditions =>{:status=>true})
    @subject = Subject.find(params[:id1])
    @employees = Employee.find_all_by_employee_department_id(Employee.find(params[:id]).employee_department_id)
    if TimetableEntry.find_all_by_subject_id_and_employee_id(@subject.id,params[:id]).blank?
      EmployeesSubject.find_by_employee_id_and_subject_id(params[:id], params[:id1]).destroy
    else
      flash.now[:warn_notice]="<p>#{t('employee.flash41')}</p> <p>#{t('employee.flash42')}</p> "
    end
    @assigned_employee = EmployeesSubject.find_all_by_subject_id(@subject.id)
    render :partial =>"select_department"
  end

  def timetable
    @employee = Employee.find(params[:id])
    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
    @employee_subjects = @employee.subjects
    @employee_timetable_subjects = @employee_subjects.map {|sub| sub.elective_group_id.nil? ? sub : sub.elective_group.subjects}.flatten!
    @subject_timetable_entries = @employee_timetable_subjects.map{|esub| esub.timetable_entries}
    @employee_subjects_ids = @employee_subjects.map {|sub| sub.id}
    @weekday_timetable = Hash.new
    @subject_timetable_entries.each do  |subtt|
      subtt.each do |tte|
        if tte.employee_id == @employee.id
          @weekday_timetable[tte.weekday.weekday] ||=[]
          @weekday_timetable[tte.weekday.weekday] << tte
        end
      end
    end
  end

  def timetable_pdf
    @employee = Employee.find(params[:id])
    @weekday = ["#{t('sun')}", "#{t('mon')}", "#{t('tue')}", "#{t('wed')}", "#{t('thu')}", "#{t('fri')}", "#{t('sat')}"]
    @employee_subjects = @employee.subjects
    @employee_timetable_subjects = @employee_subjects.map {|sub| sub.elective_group_id.nil? ? sub : sub.elective_group.subjects}.flatten!
    @subject_timetable_entries = @employee_timetable_subjects.map{|esub| esub.timetable_entries}
    @employee_subjects_ids = @employee_subjects.map {|sub| sub.id}
    @weekday_timetable = Hash.new
    @subject_timetable_entries.each do  |subtt|
      subtt.each do |tte|
        if tte.employee_id == @employee.id
          @weekday_timetable[tte.weekday.weekday] ||=[]
          @weekday_timetable[tte.weekday.weekday] << tte
        end
      end
    end
    render :pdf=>'timetable_pdf'

  end
  #HR Management special methods...

  def hr
    user = current_user
    @employee = user.employee_record
  end

  def select_department_employee
    @departments = EmployeeDepartment.active
    @employees = []
  end

  def rejected_payslip
    @departments = EmployeeDepartment.active
    @employees = []
  end

  def update_rejected_employee_list
    department_id = params[:department_id]
    #@employees = Employee.find_all_by_employee_department_id(department_id)
    @employees = MonthlyPayslip.find(:all, :conditions =>"is_rejected is true", :group=>'employee_id', :joins=>"INNER JOIN employees on monthly_payslips.employee_id = employees.id")
    @employees.reject!{|x| x.employee.employee_department_id != department_id.to_i}
    

    render :update do |page|
      page.replace_html 'employees_select_list', :partial => 'rejected_employee_select_list', :object => @employees
    end
  end

  def edit_rejected_payslip
    @salary_date = params[:id2]
    @employee = Employee.find(params[:id])
    @monthly_payslips = MonthlyPayslip.find_all_by_salary_date(@salary_date,
      :conditions=> "employee_id =#{params[:id]}",
      :order=> "payroll_category_id ASC")
    @individual = IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(@employee.id,@salary_date)
    @independent_categories = PayrollCategory.find_all_by_payroll_category_id_and_status(nil, true)
    @dependent_categories = PayrollCategory.find_all_by_status(true, :conditions=>"payroll_category_id != \'\'")
    @employee_additional_categories = IndividualPayslipCategory.find_all_by_employee_id(@employee.id, :conditions=>"include_every_month = true")
    @new_payslip_category = IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(@employee.id,nil)
    @user = current_user
    

    if request.post?
      salary_date = Date.parse(params[:salary_date])
      start_date = salary_date - ((salary_date.day - 1).days)
      end_date = start_date + 1.month
      payslip_exists = MonthlyPayslip.find_all_by_employee_id(@employee.id,
        :conditions => ["salary_date >= ? and salary_date < ?", start_date, end_date])
      payslip_exists.each do |p|
        p.delete
      end
      
      params[:manage_payroll].each_pair do |k, v|
        row_id = EmployeeSalaryStructure.find_by_employee_id_and_payroll_category_id(@employee, k)
        category_name = PayrollCategory.find(k).name
        unless row_id.nil?
          MonthlyPayslip.create(:salary_date=>start_date,:employee_id => params[:id],
            :payroll_category_id => k,:amount => v['amount'])
        else
          MonthlyPayslip.create(:salary_date=>start_date,:employee_id => params[:id],
            :payroll_category_id => k,:amount => v['amount'])
        end
      end
      individual_payslip_category = IndividualPayslipCategory.find_all_by_employee_id_and_salary_date(@employee.id,nil)
      individual_payslip_category.each do |c|
        IndividualPayslipCategory.update(c.id, :salary_date=>start_date)
      end
      privilege = Privilege.find_by_name("FinanceControl")
      available_user_ids = privilege.user_ids
      subject = "#{t('rejected_payslip_regenerated')}"
      body = "#{t('payslip_has_been_generated_for')}"+@employee.first_name+" "+@employee.last_name + " (#{t('employee_number')} :#{@employee.employee_number})" + " #{t('for_the_month')} #{salary_date.to_date.strftime("%B %Y")}. #{t('kindly_approve')}"
      Delayed::Job.enqueue(DelayedReminderJob.new( :sender_id  => @user.id,
          :recipient_ids => available_user_ids,
          :subject=>subject,
          :body=>body ))
      flash[:notice] = "#{@employee.first_name} #{t('flash27')} #{params[:salary_date]}"
      redirect_to :controller => "employee", :action => "profile", :id=> @employee.id
      
    end
  end
  def update_rejected_payslip
    @salary_date = params[:salary_date]
    @employee = Employee.find(params[:emp_id])
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value

    if params[:salary_date] == ""
      render :update do |page|
        page.replace_html "payslip_view", :text => ""
      end
      return
    end
    @monthly_payslips = MonthlyPayslip.find_all_by_salary_date(@salary_date,
      :conditions=> "employee_id =#{params[:emp_id]}",
      :order=> "payroll_category_id ASC")

    @individual_payslip_category = IndividualPayslipCategory.find_all_by_salary_date(@salary_date,
      :conditions=>"employee_id =#{params[:emp_id]}",
      :order=>"id ASC")
    @individual_category_non_deductionable = 0
    @individual_category_deductionable = 0
    @individual_payslip_category.each do |pc|
      unless pc.is_deduction == true
        @individual_category_non_deductionable = @individual_category_non_deductionable + pc.amount.to_i
      end
    end

    @individual_payslip_category.each do |pc|
      unless pc.is_deduction == false
        @individual_category_deductionable = @individual_category_deductionable + pc.amount.to_i
      end
    end

    @non_deductionable_amount = 0
    @deductionable_amount = 0
    @monthly_payslips.each do |mp|
      category1 = PayrollCategory.find(mp.payroll_category_id)
      unless category1.is_deduction == true
        @non_deductionable_amount = @non_deductionable_amount + mp.amount.to_i
      end
    end

    @monthly_payslips.each do |mp|
      category2 = PayrollCategory.find(mp.payroll_category_id)
      unless category2.is_deduction == false
        @deductionable_amount = @deductionable_amount + mp.amount.to_i
      end
    end

    @net_non_deductionable_amount = @individual_category_non_deductionable + @non_deductionable_amount
    @net_deductionable_amount = @individual_category_deductionable + @deductionable_amount

    @net_amount = @net_non_deductionable_amount - @net_deductionable_amount

    render :update do |page|
      page.replace_html 'rejected_payslip', :partial => 'rejected_payslip'
    end
  end
  def view_rejected_payslip

    @payslips = MonthlyPayslip.find_all_by_employee_id(params[:id], :conditions =>"is_rejected is true", :group=>'salary_date')
    
  end

  def update_employee_select_list
    department_id = params[:department_id]
    @employees = Employee.find_all_by_employee_department_id(department_id)

    render :update do |page|
      page.replace_html 'employees_select_list', :partial => 'employee_select_list', :object => @employees
    end
  end

  def payslip_date_select
    render :partial=>"one_click_payslip_date"
  end

  def one_click_payslip_generation

    @user = current_user
    finance_manager = find_finance_managers
    finance = Configuration.find_by_config_value("Finance")
    subject = "#{t('payslip_generated')}"
    body = "#{t('message_body')}"
    salary_date = Date.parse(params[:salary_date])
    start_date = salary_date - ((salary_date.day - 1).days)
    end_date = start_date + 1.month
    employees = Employee.find(:all)
    unless(finance_manager.nil? and finance.nil?)
      finance_manager_ids = Privilege.find_by_name('FinanceControl').user_ids
      Delayed::Job.enqueue(DelayedReminderJob.new( :sender_id  => @user.id,
          :recipient_ids => finance_manager_ids,
          :subject=>subject,
          :body=>body ))
      employees.each do|e|
        payslip_exists = MonthlyPayslip.find_all_by_employee_id(e.id,
          :conditions => ["salary_date >= ? and salary_date < ?", start_date, end_date])
        if payslip_exists == []
          salary_structure = EmployeeSalaryStructure.find_all_by_employee_id(e.id)
          unless salary_structure == []
            salary_structure.each do |ss|
              MonthlyPayslip.create(:salary_date=>start_date,
                :employee_id=>e.id,
                :payroll_category_id=>ss.payroll_category_id,
                :amount=>ss.amount,:is_approved => false,:approver => nil)
            end
          end
        end
      end
    else
      employees.each do|e|
        payslip_exists = MonthlyPayslip.find_all_by_employee_id(e.id,
          :conditions => ["salary_date >= ? and salary_date < ?", start_date, end_date])
        if payslip_exists == []
          salary_structure = EmployeeSalaryStructure.find_all_by_employee_id(e.id)
          unless salary_structure == []
            salary_structure.each do |ss|
              MonthlyPayslip.create(:salary_date=>start_date,
                :employee_id=>e.id,
                :payroll_category_id=>ss.payroll_category_id,
                :amount=>ss.amount,:is_approved => true,:approver => @user.id)
            end
          end
        end
      end
    end
    render :text => "<p>#{t('salary_slip_for_month')}: #{salary_date.strftime("%B")}.<br/><b>#{t('note')}:</b> #{t('employees_salary_generated_manually')}</p>"
  end

  def payslip_revert_date_select
    @salary_dates = MonthlyPayslip.find(:all, :select => "distinct salary_date")
    render :partial=>"one_click_payslip_revert_date"
  end

  def one_click_payslip_revert
    unless params[:one_click_payslip][:salary_date] == ""
      salary_date = Date.parse(params[:one_click_payslip][:salary_date])
      start_date = salary_date - ((salary_date.day - 1).days)
      end_date = start_date + 1.month
      employees = Employee.find(:all)
      employees.each do|e|
        payslip_record = MonthlyPayslip.find_all_by_employee_id(e.id,
          :conditions => ["salary_date >= ? and salary_date < ?", start_date, end_date])
        payslip_record.each do |pr|
          pr.destroy unless pr.is_approved
        end
        individual_payslip_record = IndividualPayslipCategory.find_all_by_employee_id(e.id,
          :conditions => ["salary_date >= ? and salary_date < ?", start_date, end_date])
        unless individual_payslip_record.nil?
          individual_payslip_record.each do|ipr|
            ipr.destroy unless ipr.is_approved
          end
        end
      end
      render :text=> "<p>#{t('salary_slip_reverted')}: #{salary_date.strftime("%B")}.</p>"
    else
      render :text=>"<p>#{t('please_select_month')}</p>"
    end
  end

  def leave_management
    user = current_user
    @employee = user.employee_record
    @all_employee = Employee.find(:all)
    @reporting_employees = Employee.find_all_by_reporting_manager_id(@employee.id)
    @leave_types = EmployeeLeaveType.find(:all)
    @total_leave_count = 0
    @reporting_employees.each do |e|
      @app_leaves = ApplyLeave.count(:conditions=>["employee_id =? AND viewed_by_manager =?", e.id, false])
      @total_leave_count = @total_leave_count + @app_leaves
    end
    @all_employee_total_leave_count = 0
    @all_employee.each do |a|
      @all_emp_app_leaves = ApplyLeave.count(:conditions=>["employee_id =? AND viewed_by_manager =?" , a.id, false])
      @all_employee_total_leave_count = @all_employee_total_leave_count + @all_emp_app_leaves
    end

    @leave_apply = ApplyLeave.new(params[:leave_apply])
    if request.post? and @leave_apply.save
      ApplyLeave.update(@leave_apply, :approved=> false, :viewed_by_manager=> false)
      if params[:is_half_day]
        ApplyLeave.update(@leave_apply, :is_half_day=> true)
      else
        ApplyLeave.update(@leave_apply, :is_half_day=> false)
      end
      flash[:notice]=t('flash31')
      redirect_to :controller => "employee", :action=> "leave_management", :id=>@employee.id
    end
  end

  def all_employee_leave_applications

    @employee = Employee.find(params[:id])
    @departments = EmployeeDepartment.find(:all, :order=>"name ASC")
    @employees = []
    render :partial=> "all_employee_leave_applications"
  end

  def update_employees_select
    @employee = params[:emp_id]
    department_id = params[:department_id]
    @employees = Employee.find_all_by_employee_department_id(department_id)

    render :update do |page|
      page.replace_html 'employees_select', :partial => 'employee_select', :object => @employees
    end
  end

  def leave_list
    if params[:employee_id] == ""
      render :update do |page|
        page.replace_html "leave-list", :text => "none"
      end
      return
    end
    @employee = params[:emp_id]
    @pending_applied_leaves = ApplyLeave.find_all_by_employee_id(params[:employee_id], :conditions=> "approved = false AND viewed_by_manager = false", :order=>"start_date DESC")
    @applied_leaves = ApplyLeave.find_all_by_employee_id(params[:employee_id], :conditions=> "viewed_by_manager = true", :order=>"start_date DESC")
    @all_leave_applications = ApplyLeave.find_all_by_employee_id(params[:employee_id])
    render :update do |page|
      page.replace_html "leave-list", :partial => "leave_list"
    end
  end

  def department_payslip
    @departments = EmployeeDepartment.find(:all, :conditions=>"status = true", :order=> "name ASC")
    @salary_dates = MonthlyPayslip.find(:all,:select => "distinct salary_date")
    if request.post?
      post_data = params[:payslip]
      unless post_data.blank?
        if post_data[:salary_date].present? and post_data[:department_id].present?
          @payslips = MonthlyPayslip.find_and_filter_by_department(post_data[:salary_date],post_data[:department_id])
        else
          flash[:notice] = "#{t('select_salary_date')}"
          redirect_to :action=>"department_payslip"
        end
      end
    end
  end

  def view_employee_payslip
    @monthly_payslips = MonthlyPayslip.find(:all,:conditions=>["employee_id=? AND salary_date = ?",params[:id],params[:salary_date]],:include=>:payroll_category)
    @individual_payslips =  IndividualPayslipCategory.find(:all,:conditions=>["employee_id=? AND salary_date = ?",params[:id],params[:salary_date]])
    @salary  = Employee.calculate_salary(@monthly_payslips, @individual_payslips)
  end

  #PDF methods

  def view_employee_payslip_pdf
    @employee = Employee.find(:first,:conditions => {:id => params[:id]})
    @employee ||= ArchivedEmployee.find(:first,:conditions => {:former_id => params[:id]})
    @monthly_payslips = MonthlyPayslip.find(:all,:conditions=>["employee_id=? AND salary_date = ?",params[:id],params[:salary_date]],:include=>:payroll_category)
    @individual_payslips =  IndividualPayslipCategory.find(:all,:conditions=>["employee_id=? AND salary_date = ?",params[:id],params[:salary_date]])
    @salary  = Employee.calculate_salary(@monthly_payslips, @individual_payslips)
    @salary_date = params[:salary_date] if params[:salary_date]
  end

  def department_payslip_pdf
    @department = EmployeeDepartment.find(params[:department])
    @employees = Employee.find_all_by_employee_department_id(@department.id)


    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    @salary_date = params[:salary_date] if params[:salary_date]
   
    render :pdf => 'department_payslip_pdf',
      :margin => {    :top=> 10,
      :bottom => 10,
      :left=> 30,
      :right => 30}
    #    respond_to do |format|
    #      format.pdf { render :layout => false }
    #    end

  end

  def individual_payslip_pdf
    @employee = Employee.find(params[:id])
    @department = EmployeeDepartment.find(@employee.employee_department_id).name
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    @category = EmployeeCategory.find(@employee.employee_category_id).name
    @grade = EmployeeGrade.find(@employee.employee_grade_id).name unless @employee.employee_grade_id.nil?
    @position = EmployeePosition.find(@employee.employee_position_id).name
    @salary_date = Date.parse(params[:id2])
    @monthly_payslips = MonthlyPayslip.find_all_by_salary_date(@salary_date,
      :conditions=> "employee_id =#{@employee.id}",
      :order=> "payroll_category_id ASC")

    @individual_payslip_category = IndividualPayslipCategory.find_all_by_salary_date(@salary_date,
      :conditions=>"employee_id =#{@employee.id}",
      :order=>"id ASC")
    @individual_category_non_deductionable = 0
    @individual_category_deductionable = 0
    @individual_payslip_category.each do |pc|
      unless pc.is_deduction == true
        @individual_category_non_deductionable = @individual_category_non_deductionable + pc.amount.to_i
      end
    end

    @individual_payslip_category.each do |pc|
      unless pc.is_deduction == false
        @individual_category_deductionable = @individual_category_deductionable + pc.amount.to_i
      end
    end

    @non_deductionable_amount = 0
    @deductionable_amount = 0
    @monthly_payslips.each do |mp|
      category1 = PayrollCategory.find(mp.payroll_category_id)
      unless category1.is_deduction == true
        @non_deductionable_amount = @non_deductionable_amount + mp.amount.to_i
      end
    end

    @monthly_payslips.each do |mp|
      category2 = PayrollCategory.find(mp.payroll_category_id)
      unless category2.is_deduction == false
        @deductionable_amount = @deductionable_amount + mp.amount.to_i
      end
    end

    @net_non_deductionable_amount = @individual_category_non_deductionable + @non_deductionable_amount
    @net_deductionable_amount = @individual_category_deductionable + @deductionable_amount

    @net_amount = @net_non_deductionable_amount - @net_deductionable_amount
    render :pdf => 'individual_payslip_pdf'
    

    #    respond_to do |format|
    #      format.pdf { render :layout => false }
    #    end
  end
  def employee_individual_payslip_pdf
    @employee = Employee.find(:first,:conditions=>"id=#{params[:id]}")
    @bank_details = EmployeeBankDetail.find_all_by_employee_id(@employee.id)
    @employee ||= ArchivedEmployee.find(:first,:conditions=>"former_id=#{params[:id]}")
    @department = EmployeeDepartment.find(@employee.employee_department_id).name
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    @category = EmployeeCategory.find(@employee.employee_category_id).name
    @grade = EmployeeGrade.find(@employee.employee_grade_id).name unless @employee.employee_grade_id.nil?
    @position = EmployeePosition.find(@employee.employee_position_id).name
    @salary_date = Date.parse(params[:id2])
    @monthly_payslips = MonthlyPayslip.find_all_by_salary_date(@salary_date,
      :conditions=> "employee_id =#{params[:id]}",
      :order=> "payroll_category_id ASC")

    @individual_payslip_category = IndividualPayslipCategory.find_all_by_salary_date(@salary_date,
      :conditions=>"employee_id =#{params[:id]}",
      :order=>"id ASC")
    @individual_category_non_deductionable = 0
    @individual_category_deductionable = 0
    @individual_payslip_category.each do |pc|
      unless pc.is_deduction == true
        @individual_category_non_deductionable = @individual_category_non_deductionable + pc.amount.to_i
      end
    end

    @individual_payslip_category.each do |pc|
      unless pc.is_deduction == false
        @individual_category_deductionable = @individual_category_deductionable + pc.amount.to_i
      end
    end

    @non_deductionable_amount = 0
    @deductionable_amount = 0
    @monthly_payslips.each do |mp|
      category1 = PayrollCategory.find(mp.payroll_category_id)
      unless category1.is_deduction == true
        @non_deductionable_amount = @non_deductionable_amount + mp.amount.to_i
      end
    end

    @monthly_payslips.each do |mp|
      category2 = PayrollCategory.find(mp.payroll_category_id)
      unless category2.is_deduction == false
        @deductionable_amount = @deductionable_amount + mp.amount.to_i
      end
    end

    @net_non_deductionable_amount = @individual_category_non_deductionable + @non_deductionable_amount
    @net_deductionable_amount = @individual_category_deductionable + @deductionable_amount

    @net_amount = @net_non_deductionable_amount - @net_deductionable_amount
    
    render :pdf => 'individual_payslip_pdf'
    #    respond_to do |format|
    #      format.pdf { render :layout => false }
    #    end
  end
  def advanced_search
    @search = Employee.search(params[:search])
    if params[:search]
      if params[:search][:status_equals]=="true"
        @search = Employee.search(params[:search])
        @employees1 = @search.all
        @employees2 = []
      elsif params[:search][:status_equals]=="false"
        @search = ArchivedEmployee.search(params[:search])
        @employees1 = @search.all
        @employees2 = []
      else
        @search1 = Employee.search(params[:search]).all
        @search2 = ArchivedEmployee.search(params[:search]).all
        @employees1 = @search1
        @employees2 = @search2
      end
    end
  end

  def list_doj_year
    doj_option = params[:doj_option]
    if doj_option == "equal_to"
      render :update do |page|
        page.replace_html 'doj_year', :partial=>"equal_to_select"
      end
    elsif doj_option == "less_than"
      render :update do |page|
        page.replace_html 'doj_year', :partial=>"less_than_select"
      end
    else
      render :update do |page|
        page.replace_html 'doj_year', :partial=>"greater_than_select"
      end
    end
  end

  def doj_equal_to_update
    year = params[:year]
    @start_date = "#{year}-01-01".to_date
    @end_date = "#{year}-12-31".to_date
    render :update do |page|
      page.replace_html 'doj_year_hidden', :partial=>"equal_to_doj_select"
    end
  end

  def doj_less_than_update
    year = params[:year]
    @start_date = "1900-01-01".to_date
    @end_date = "#{year}-01-01".to_date
    render :update do |page|
      page.replace_html 'doj_year_hidden', :partial=>"less_than_doj_select"
    end
  end

  def doj_greater_than_update
    year = params[:year]
    @start_date = "2100-01-01".to_date
    @end_date = "#{year}-12-31".to_date
    render :update do |page|
      page.replace_html 'doj_year_hidden', :partial=>"greater_than_doj_select"
    end
  end

  def list_dob_year
    dob_option = params[:dob_option]
    if dob_option == "equal_to"
      render :update do |page|
        page.replace_html 'dob_year', :partial=>"equal_to_select_dob"
      end
    elsif dob_option == "less_than"
      render :update do |page|
        page.replace_html 'dob_year', :partial=>"less_than_select_dob"
      end
    else
      render :update do |page|
        page.replace_html 'dob_year', :partial=>"greater_than_select_dob"
      end
    end
  end

  def dob_equal_to_update
    year = params[:year]
    @start_date = "#{year}-01-01".to_date
    @end_date = "#{year}-12-31".to_date
    render :update do |page|
      page.replace_html 'dob_year_hidden', :partial=>"equal_to_dob_select"
    end
  end

  def dob_less_than_update
    year = params[:year]
    @start_date = "1900-01-01".to_date
    @end_date = "#{year}-01-01".to_date
    render :update do |page|
      page.replace_html 'dob_year_hidden', :partial=>"less_than_dob_select"
    end
  end

  def dob_greater_than_update
    year = params[:year]
    @start_date = "2100-01-01".to_date
    @end_date = "#{year}-12-31".to_date
    render :update do |page|
      page.replace_html 'dob_year_hidden', :partial=>"greater_than_dob_select"
    end
  end

  def remove
    @employee = Employee.find(params[:id])
    associate_employee = Employee.find(:all, :conditions=>["reporting_manager_id=#{@employee.id}"])
    unless associate_employee.blank?
      flash[:notice] = t('flash35')
      redirect_to :action=>'remove_subordinate_employee', :id=>@employee.id
    end
  end

  def remove_subordinate_employee
    @current_manager = Employee.find(params[:id])
    @associate_employee = Employee.find(:all, :conditions=>["reporting_manager_id=#{@current_manager.id}"])
    @departments = EmployeeDepartment.find(:all)
    @categories  = EmployeeCategory.find(:all)
    @positions   = EmployeePosition.find(:all)
    @grades      = EmployeeGrade.find(:all)
    if request.post?
      @associate_employee.each do |e|
        Employee.update(e, :reporting_manager_id => params[:employee][:reporting_manager_id])
      end
      redirect_to :action => "remove", :id=>@current_manager.id
    end
  end

  def change_to_former
    @employee = Employee.find(params[:id])
    @dependency = @employee.former_dependency
    if request.post?
      flash[:notice]= "#{t('flash32')}  #{@employee.employee_number}"
      EmployeesSubject.destroy_all(:employee_id=>@employee.id)
      @employee.archive_employee(params[:remove][:status_description])
      redirect_to :action => "hr"
    end
  end

  def delete
    employee = Employee.find(params[:id])
    unless employee.has_dependency
      employee_subject=EmployeesSubject.destroy_all(:employee_id=>employee.id)
      employee.destroy
      flash[:notice] = "#{t('flash46')}#{employee.employee_number}."
      redirect_to :controller => 'user', :action => 'dashboard'
    else
      flash[:notice] = "#{t('flash44')}"
      redirect_to  :action => 'remove' ,:id=>employee.id
    end
  end

  def advanced_search_pdf
    @employee_ids2 = params[:result2]
    @employee_ids = params[:result]
    @searched_for = params[:for]
    @status = params[:status]
    @employees1 = []
    @employees2 = []
    if params[:status] == 'true'
      @employee_ids.each do |s|
        employee = Employee.find(s)
        @employees1.push employee
      end
    elsif params[:status] == 'false'
      @employee_ids.each do |s|
        employee = ArchivedEmployee.find(s)
        @employees1.push employee
      end
    elsif @employee_ids.present?
      @employee_ids.each do |s|
        employee = Employee.find(s)
        @employees1.push employee
      end
      unless @employee_ids2.nil?
        @employee_ids2.each do |s|
          employee = ArchivedEmployee.find(s)
          @employees2.push employee
        end
      end
    end
    render :pdf => 'employee_advanced_search_pdf'
  end


  def payslip_approve
    @salary_dates = MonthlyPayslip.find(:all, :select => "distinct salary_date")
  end

  def one_click_approve
    @dates = MonthlyPayslip.find_all_by_salary_date(params[:salary_date],:conditions => ["is_approved = false"])
    @salary_date = params[:salary_date]
    render :update do |page|
      page.replace_html "approve",:partial=> "one_click_approve"
    end
  end

  def one_click_approve_submit
    dates = MonthlyPayslip.find_all_by_salary_date(Date.parse(params[:date]))

    dates.each do |d|
      d.approve(current_user.id)
    end
    flash[:notice] = t('flash34')
    redirect_to :action => "hr"

  end

end
