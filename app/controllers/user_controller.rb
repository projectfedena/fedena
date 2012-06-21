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

class UserController < ApplicationController
  layout :choose_layout
  before_filter :login_required, :except => [:forgot_password, :login, :set_new_password, :reset_password]
  before_filter :only_admin_allowed, :only => [:edit, :create, :index, :edit_privilege, :user_change_password,:delete,:list_user,:all]
  before_filter :protect_user_data, :only => [:profile, :user_change_password]
  before_filter :check_if_loggedin, :only => [:login]
  #  filter_access_to :edit_privilege
  def choose_layout
    return 'login' if action_name == 'login' or action_name == 'set_new_password'
    return 'forgotpw' if action_name == 'forgot_password'
    return 'dashboard' if action_name == 'dashboard'
    'application'
  end
  
  def all
    @users = User.all
  end
  
  def list_user
    if params[:user_type] == 'Admin'
      @users = User.find(:all, :conditions => {:admin => true}, :order => 'first_name ASC')
      render(:update) do |page|
        page.replace_html 'users', :partial=> 'users'
        page.replace_html 'employee_user', :text => ''
        page.replace_html 'student_user', :text => ''
      end
    elsif params[:user_type] == 'Employee'
      render(:update) do |page|
        hr = Configuration.find_by_config_value("HR")
        unless hr.nil?
          page.replace_html 'employee_user', :partial=> 'employee_user'
          page.replace_html 'users', :text => ''
          page.replace_html 'student_user', :text => ''
        else
          @users = User.find_all_by_employee(1)
          page.replace_html 'users', :partial=> 'users'
          page.replace_html 'employee_user', :text => ''
          page.replace_html 'student_user', :text => ''
        end
      end
    elsif params[:user_type] == 'Student'
      render(:update) do |page|
        page.replace_html 'student_user', :partial=> 'student_user'
        page.replace_html 'users', :text => ''
        page.replace_html 'employee_user', :text => ''
      end
    elsif params[:user_type] == "Parent"
      render(:update) do |page|
        page.replace_html 'student_user', :partial=> 'parent_user'
        page.replace_html 'users', :text => ''
        page.replace_html 'employee_user', :text => ''
      end
    elsif params[:user_type] == ''
      @users = ""
      render(:update) do |page|
        page.replace_html 'users', :partial=> 'users'
        page.replace_html 'employee_user', :text => ''
        page.replace_html 'student_user', :text => ''
      end
    end
  end

  def list_employee_user
    emp_dept = params[:dept_id]
    @employee = Employee.find_all_by_employee_department_id(emp_dept, :order =>'first_name ASC')
    @users = @employee.collect { |employee| employee.user}
    @users.delete(nil)
    render(:update) {|page| page.replace_html 'users', :partial=> 'users'}
  end

  def list_student_user
    batch = params[:batch_id]
    @student = Student.find_all_by_batch_id(batch, :conditions => { :is_active => true },:order =>'first_name ASC')
    @users = @student.collect { |student| student.user}
    @users.delete(nil)
    render(:update) {|page| page.replace_html 'users', :partial=> 'users'}
  end

  def list_parent_user
    batch = params[:batch_id]
    @guardian = Guardian.find(:all, :select=>'guardians.*',:joins=>'INNER JOIN students ON students.id = guardians.ward_id', :conditions => 'students.batch_id = ' + batch + ' AND is_active=1',:order =>'first_name ASC')
    users = @guardian.collect { |g| g.user}
    users.compact!
    @users  = users.paginate(:page=>params[:page],:per_page=>20)
    render(:update) {|page| page.replace_html 'users', :partial=> 'users'}
  end

  def change_password
    
    if request.post?
      @user = current_user
      if User.authenticate?(@user.username, params[:user][:old_password])
        if params[:user][:new_password] == params[:user][:confirm_password]
          @user.password = params[:user][:new_password]
          @user.update_attributes(:password => @user.password,
            :role => @user.role_name
          )
          flash[:notice] = "#{t('flash9')}"
          redirect_to :action => 'dashboard'
        else
          flash[:warn_notice] = "<p>#{t('flash10')}</p>"
        end
      else
        flash[:warn_notice] = "<p>#{t('flash11')}</p>"
      end
    end
  end

  def user_change_password
    @user = User.find_by_username(params[:id])

    if request.post?
      if params[:user][:new_password]=='' and params[:user][:confirm_password]==''
        flash[:warn_notice]= "<p>#{t('flash6')}</p>"
      else
        if params[:user][:new_password] == params[:user][:confirm_password]
          @user.password = params[:user][:new_password]
          if @user.update_attributes(:password => @user.password,:role => @user.role_name)
            flash[:notice]= "#{t('flash7')}"
            redirect_to :action=>"edit", :id=>@user.username
          else
            render :user_change_password
          end
        else
          flash[:warn_notice] =  "<p>#{t('flash10')}</p>"
        end
      end

      
    end
  end

  def create
    @config = Configuration.available_modules

    @user = User.new(params[:user])
    if request.post?
          
      if @user.save
        flash[:notice] = "#{t('flash17')}"
        redirect_to :controller => 'user', :action => 'edit', :id => @user.username
      else
        flash[:notice] = "#{t('flash16')}"
      end
           
    end
  end

  def delete
    @user = User.find_by_username(params[:id],:conditions=>"admin = 1")
    unless @user.nil?
      if @user.employee_record.nil?
        flash[:notice] = "#{t('flash12')}" if @user.destroy
      end
    end
    redirect_to :controller => 'user'
  end
  
  def dashboard
    @user = current_user
    @config = Configuration.available_modules
    @employee = @user.employee_record if ['employee','admin'].include?(@user.role_name.downcase)
    if @user.student?
      @student = Student.find_by_admission_no(@user.username)
    end
    if @user.parent?
      @student = Student.find_by_admission_no(@user.username[1..@user.username.length])
    end
    #    @dash_news = News.find(:all, :limit => 3)
  end

  def edit
    @user = User.find_by_username(params[:id])
    @current_user = current_user
    if request.post? and @user.update_attributes(params[:user])
      flash[:notice] = "#{t('flash13')}"
      redirect_to :controller => 'user', :action => 'profile', :id => @user.username
    end
  end

  def forgot_password
    #    flash[:notice]="You do not have permission to access forgot password!"
    #    redirect_to :action=>"login"
    @network_state = Configuration.find_by_config_key("NetworkState")
    if request.post? and params[:reset_password]
      if user = User.find_by_username(params[:reset_password][:username])
        unless user.email.blank?
          user.reset_password_code = Digest::SHA1.hexdigest( "#{user.email}#{Time.now.to_s.split(//).sort_by {rand}.join}" )
          user.reset_password_code_until = 1.day.from_now
          user.role = user.role_name
          user.save(false)
          url = "#{request.protocol}#{request.host_with_port}"
          UserNotifier.deliver_forgot_password(user,url)
          flash[:notice] = "#{t('flash18')}"
          redirect_to :action => "index"
        else
          flash[:notice] = "#{t('flash20')}"
          return
        end
      else
        flash[:notice] = "#{t('flash19')} #{params[:reset_password][:username]}"
      end
    end
  end


  def login
    @institute = Configuration.find_by_config_key("LogoName")
    available_login_authes = FedenaPlugin::AVAILABLE_MODULES.select{|m| m[:name].classify.constantize.respond_to?("login_hook")}
    selected_login_hook = available_login_authes.first if available_login_authes.count>=1
    if selected_login_hook
      authenticated_user = selected_login_hook[:name].classify.constantize.send("login_hook",self)
    else
      if request.post? and params[:user]
        @user = User.new(params[:user])
        user = User.find_by_username @user.username
        if user.present? and User.authenticate?(@user.username, @user.password)
          authenticated_user = user 
        end
      end
    end
    if authenticated_user.present?
      successful_user_login(authenticated_user) and return
    elsif authenticated_user.blank? and request.post?
      flash[:notice] = "#{t('login_error_message')}"
    end
  end

  def logout
    Rails.cache.delete("user_main_menu#{session[:user_id]}")
    Rails.cache.delete("user_autocomplete_menu#{session[:user_id]}")
    session[:user_id] = nil
    session[:language] = nil
    flash[:notice] = "#{t('logged_out')}"
    available_login_authes = FedenaPlugin::AVAILABLE_MODULES.select{|m| m[:name].classify.constantize.respond_to?("logout_hook")}
    selected_logout_hook = available_login_authes.first if available_login_authes.count>=1
    if selected_logout_hook
      selected_logout_hook[:name].classify.constantize.send("logout_hook",self,"/")
    else
      redirect_to :controller => 'user', :action => 'login' and return
    end    
  end

  def profile
    @config = Configuration.available_modules
    @current_user = current_user
    @username = @current_user.username if session[:user_id]
    @user = User.find_by_username(params[:id])
    unless @user.nil?
      @employee = Employee.find_by_employee_number(@user.username)
      @student = Student.find_by_admission_no(@user.username)
      @ward  = @user.parent_record if @user.parent

    else
      flash[:notice] = "#{t('flash14')}"
      redirect_to :action => 'dashboard'
    end
  end

  def reset_password
    user = User.find_by_reset_password_code(params[:id],:conditions=>"reset_password_code IS NOT NULL")
    if user
      if user.reset_password_code_until > Time.now
        redirect_to :action => 'set_new_password', :id => user.reset_password_code
      else
        flash[:notice] = "#{t('flash1')}"
        redirect_to :action => 'index'
      end
    else
      flash[:notice]= "#{t('flash2')}"
      redirect_to :action => 'index'
    end
  end

  def search_user_ajax
    unless params[:query].nil? or params[:query].empty? or params[:query] == ' '
      #      if params[:query].length>= 3
      #        @user = User.first_name_or_last_name_or_username_begins_with params[:query].split
      @user = User.find(:all,
        :conditions => "(first_name LIKE \"#{params[:query]}%\"
                       OR last_name LIKE \"#{params[:query]}%\"
                       OR (concat(first_name, \" \", last_name) LIKE \"#{params[:query]}%\")
                       OR username LIKE  \"#{params[:query]}\")",
        :order => "first_name asc") unless params[:query] == ''
      #      else
      #        @user = User.first_name_or_last_name_or_username_equals params[:query].split
      #      end
      #      @user = @user.sort_by { |u1| [u1.role_name,u1.full_name] } unless @user.nil?
    else
      @user = ''
    end
    render :layout => false
  end

  def set_new_password
    if request.post?
      user = User.find_by_reset_password_code(params[:id],:conditions=>"reset_password_code IS NOT NULL")
      if user
        if params[:set_new_password][:new_password] === params[:set_new_password][:confirm_password]
          user.password = params[:set_new_password][:new_password]
          user.update_attributes(:password => user.password, :reset_password_code => nil, :reset_password_code_until => nil, :role => user.role_name)
          user.clear_menu_cache
          #User.update(user.id, :password => params[:set_new_password][:new_password],
          # :reset_password_code => nil, :reset_password_code_until => nil)
          flash[:notice] = "#{t('flash3')}"
          redirect_to :action => 'index'
        else
          flash[:notice] = "#{t('user.flash4')}"
          redirect_to :action => 'set_new_password', :id => user.reset_password_code
        end
      else
        flash[:notice] = "#{t('flash5')}"
        redirect_to :action => 'index'
      end
    end
  end

  def edit_privilege
    @privileges = Privilege.find(:all)
    @user = User.find_by_username(params[:id])
    @finance = Configuration.find_by_config_value("Finance")
    @sms_setting = SmsSetting.new()
    @hr = Configuration.find_by_config_value("HR")
    if request.post?
      new_privileges = params[:user][:privilege_ids] if params[:user]
      new_privileges ||= []
      @user.privileges = Privilege.find_all_by_id(new_privileges)
      @user.clear_menu_cache
      flash[:notice] = "#{t('flash15')}"
      redirect_to :action => 'profile',:id => @user.username
    end
  end

  def header_link
    @user = current_user
    #@reminders = @users.check_reminders
    @config = Configuration.available_modules
    @employee = Employee.find_by_employee_number(@user.username)
    @employee ||= Employee.first if current_user.admin?
    @student = Student.find_by_admission_no(@user.username)
    render :partial=>'header_link'
  end


  private
  def successful_user_login(user)
    session[:user_id] = user.id
    flash[:notice] = "#{t('welcome')}, #{user.first_name} #{user.last_name}!"
    redirect_to session[:back_url] || {:controller => 'user', :action => 'dashboard'}
  end
end

