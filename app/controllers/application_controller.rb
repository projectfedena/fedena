class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery # :secret => '434571160a81b5595319c859d32060c1'
  filter_parameter_logging :password
  
  before_filter { |c| Authorization.current_user = c.current_user }
  before_filter :message_user
  before_filter :set_user_language


    def set_language
    session[:language] = params[:language]
    render :update do |page|
      page.reload
    end
  end


  if Rails.env.production?
    rescue_from ActiveRecord::RecordNotFound do |exception|
      flash[:notice] = "Sorry , #{exception} ."
      redirect_to :controller=>:user ,:action=>:dashboard
    end

    rescue_from NoMethodError do |exception|
      flash[:notice] = "Sorry, an error occured .Please contact Administrator."
      redirect_to :controller=>:user ,:action=>:dashboard
    end
  end

 
  def only_assigned_employee_allowed
    if @current_user.employee?
      @employee_subjects= @current_user.employee_record.subjects.map { |n| n.subject_id}
      if @employee_subjects.empty?
        flash[:notice] = "Sorry, you are not allowed to access that page."
        redirect_to :controller => 'user', :action => 'dashboard'
      else
        @allow_access = true
      end
    end
  end

  def restrict_employees_from_exam
    if @current_user.employee?
      @employee_subjects= @current_user.employee_record.subjects.map { |n| n.subject_id}
      if @employee_subjects.empty? and !@current_user.privileges.map{|p| p.id}.include?(1) and !@current_user.privileges.map{|p| p.id}.include?(2) and !@current_user.privileges.map{|p| p.id}.include?(3)
        flash[:notice] = "Sorry, you are not allowed to access that page."
        redirect_to :controller => 'user', :action => 'dashboard'
      else
        @allow_for_exams = true
      end
    end
  end

  def block_unauthorised_entry
    if @current_user.employee?
      @employee_subjects= @current_user.employee_record.subjects.map { |n| n.subject_id}
      if @employee_subjects.empty? and !@current_user.privileges.map{|p| p.id}.include?(1)
        flash[:notice] = "Sorry, you are not allowed to access that page."
        redirect_to :controller => 'user', :action => 'dashboard'
      else
        @allow_for_exams = true
      end
    end
  end
  
  def initialize
    @title = 'Fedena'
  end

  def message_user
    @current_user = current_user
  end

  def current_user
    User.find(session[:user_id]) unless session[:user_id].nil?
  end

  
  def find_finance_managers
    Privilege.find_by_name('FinanceControl').users
  end

  def permission_denied
    flash[:notice] = "Sorry, you are not allowed to access that page."
    redirect_to :controller => 'user', :action => 'dashboard'
  end
  
  protected
  def login_required
    redirect_to '/' unless session[:user_id]
  end

  def configuration_settings_for_hr
    hr = Configuration.find_by_config_value("HR")
    if hr.nil?
      redirect_to :controller => 'user', :action => 'dashboard'
      flash[:notice] = "Sorry, you are not allowed to access that page."
    end
  end

  

  def configuration_settings_for_finance
    finance = Configuration.find_by_config_value("Finance")
    if finance.nil?
      redirect_to :controller => 'user', :action => 'dashboard'
      flash[:notice] = "Sorry, you are not allowed to access that page."
    end
  end

  def only_admin_allowed
    redirect_to :controller => 'user', :action => 'dashboard' unless current_user.admin?
  end

  def protect_other_student_data
    if current_user.student?
      student = Student.find_by_admission_no(current_user.username)
      unless params[:id].to_i == student.id or params[:student].to_i == student.id
        flash[:notice] = "You are not allowed to view that information."
        redirect_to :controller=>"user", :action=>"dashboard"
      end
    end
  end

  def protect_other_employee_data
    if current_user.employee?
      employee = Employee.find_by_employee_number(current_user.username)
      #    pri = Privilege.find(:all,:select => "privilege_id",:conditions=> 'privileges_users.user_id = ' + current_user.id.to_s, :joins =>'INNER JOIN `privileges_users` ON `privileges`.id = `privileges_users`.privilege_id' )
      #    privilege =[]
      #    pri.each do |p|
      #      privilege.push p.privilege_id
      #    end
      #    unless privilege.include?('9') or privilege.include?('14') or privilege.include?('17') or privilege.include?('18') or privilege.include?('19')
      unless params[:id].to_i == employee.id
        flash[:notice] = 'You are not allowed to view that information.'
        redirect_to :controller=>"user", :action=>"dashboard"
      end
    end
  end

  def protect_leave_history
   if current_user.employee?
   employee = Employee.find(params[:id])
   employee_user = employee.user
    unless employee_user.id == current_user.id
        unless current_user.role_symbols.include?(:hr_basics) or current_user.role_symbols.include?(:employee_attendance)
      flash[:notice] = "Access denied"
      redirect_to :controller=>"user", :action=>"dashboard"
        end
    end
  end
  end
  #  end

  #reminder filters
  def protect_view_reminders
    reminder = Reminder.find(params[:id2])
    unless reminder.recipient == current_user.id
      flash[:notice] = 'You are not allowed to view that information.'
      redirect_to :controller=>"reminder", :action=>"index"
    end
  end

  def protect_sent_reminders
    reminder = Reminder.find(params[:id2])
    unless reminder.sender == current_user.id
      flash[:notice] = 'You are not allowed to view that information.'
      redirect_to :controller=>"reminder", :action=>"index"
    end
  end

  #employee_leaves_filters
  def protect_leave_dashboard
    employee = Employee.find(params[:id])
    employee_user = employee.user
    #    unless permitted_to? :employee_attendance_pdf, :employee_attendance
    unless employee_user.id == current_user.id
      flash[:notice] = "Access denied"
      redirect_to :controller=>"user", :action=>"dashboard"
      #    end
    end
  end

  def protect_applied_leave
    applied_leave = ApplyLeave.find(params[:id])
    applied_employee = applied_leave.employee
    applied_employee_user = applied_employee.user
    unless applied_employee_user.id == current_user.id
      flash[:notice]="Access denied!"
      redirect_to :controller=>"user", :action=>"dashboard"
    end
  end

  def protect_manager_leave_application_view
    applied_leave = ApplyLeave.find(params[:id])
    applied_employee = applied_leave.employee
    applied_employees_manager = Employee.find(applied_employee.reporting_manager_id)
    applied_employees_manager_user = applied_employees_manager.user
    unless applied_employees_manager_user.id == current_user.id
      flash[:notice]="Access denied!"
      redirect_to :controller=>"user", :action=>"dashboard"
    end
  end


 private
  def set_user_language
    lan = Configuration.find_by_config_key("Locale")
    I18n.default_locale = lan.config_value
    Translator.fallback(true)
    if session[:language].nil?
      I18n.locale = lan.config_value
    else
      I18n.locale = session[:language]
    end
  end
end