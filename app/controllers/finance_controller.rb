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

class FinanceController < ApplicationController
  before_filter :login_required,:configuration_settings_for_finance
  filter_access_to :all
  
  def index
    @hr = Configuration.find_by_config_value("HR")
  end
  
  def automatic_transactions
    @cat_names = ["'Fee'","'Salary'"]
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      @cat_names << "'#{category[:category_name]}'"
    end
    @triggers = FinanceTransactionTrigger.all
    @categories = FinanceTransactionCategory.find(:all ,:conditions => ["name NOT IN (#{@cat_names.join(',')}) and is_income=1 and deleted=0 "])
  end
  
  def donation
    @donation = FinanceDonation.new(params[:donation])
    if request.post? and @donation.save
      flash[:notice] = "#{t('flash1')}"
      redirect_to :action => 'donation_receipt', :id => @donation.id
    end
  end

  def donation_receipt
    @donation = FinanceDonation.find(params[:id])
  end

  def donation_edit
    @donation = FinanceDonation.find(params[:id])
    @transaction = FinanceTransaction.find(@donation.transaction_id)
    if request.post? and @donation.update_attributes(params[:donation])
      donor = "#{t('flash15')} #{params[:donation][:donor]}"
      FinanceTransaction.update(@transaction.id, :description => params[:donation][:description], :title=>donor, :amount=>params[:donation][:amount], :transaction_date=>@donation.transaction_date)
      redirect_to :action => 'donors'
      flash[:notice] = "#{t('flash16')}"
    end
  end
  
  def donation_delete
    @donation = FinanceDonation.find(params[:id])
    @transaction = FinanceTransaction.find(@donation.transaction_id)
    if  @donation.destroy
      @transaction.destroy
      redirect_to :action => 'donors'
      flash[:notice] = "#{t('flash25')}"
    end
  end

  def donation_receipt_pdf
    @donation = FinanceDonation.find(params[:id])
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    render :pdf => 'donation_receipt_pdf'
    
  end

  def donors
    @donations = FinanceDonation.find(:all, :order => 'transaction_date desc')
  end

  def expense_create
    flash[:notice]=nil
    @expense = FinanceTransaction.new(params[:transaction])
    @categories = FinanceTransactionCategory.expense_categories
    if @categories.empty?
      flash[:notice] = "#{t('flash2')}"
    end
    if request.post? and @expense.save
      flash[:notice] = "#{t('flash3')}"
    end
  end

  def expense_edit
    @transaction = FinanceTransaction.find(params[:id])
    @categories = FinanceTransactionCategory.all(:conditions =>"name != 'Salary' and is_income = false" )
    if request.post? and @transaction.update_attributes(params[:transaction])
      flash[:notice] = "#{t('flash4')}"
      redirect_to  :action=>:expense_list
    end
  end

  def expense_list
  end

  def expense_list_update
    if params[:start_date].to_date > params[:end_date].to_date
      flash[:warn_notice] = "#{t('flash17')}"
      redirect_to :action => 'expense_list'
    end
    @start_date = (params[:start_date]).to_date
    @end_date = (params[:end_date]).to_date
    @expenses = FinanceTransaction.expenses(@start_date,@end_date)
  end

  def expense_list_pdf
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    @start_date = (params[:start_date]).to_date
    @end_date = (params[:end_date]).to_date
    @expenses = FinanceTransaction.expenses(@start_date,@end_date)
    render :pdf => 'expense_list_pdf'
  end
  
  def income_create
    flash[:notice]=nil
    @income = FinanceTransaction.new(params[:transaction])
    @categories = FinanceTransactionCategory.income_categories
    if @categories.empty?
      flash[:notice] = "#{t('flash5')}"
    end
    if request.post? and @income.save
      flash[:notice] = "#{t('flash6')}"
    end
  end

  def monthly_income
    
  end

  def income_edit
    @cat_names = ["'Fee'","'Salary'","'Donation'"]
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      @cat_names << "'#{category[:category_name]}'"
    end
    @transaction = FinanceTransaction.find(params[:id])
    @categories = FinanceTransactionCategory.all(:conditions => "is_income=true and name NOT IN (#{@cat_names.join(',')})")
    if request.post? and @transaction.update_attributes(params[:transaction])
      flash[:notice] = "#{t('flash7')}"
      redirect_to :action=> 'income_list'
    end
  end

  def income_list
  end

  def delete_transaction
    @transaction = FinanceTransaction.find_by_id(params[:id])
    income = @transaction.category.is_income?
    if income
      auto_transactions = FinanceTransaction.find_all_by_master_transaction_id(params[:id])
      auto_transactions.each { |a| a.destroy } unless auto_transactions.nil?
    end
    @transaction.destroy
    flash[:notice]="#{t('flash18')}"
    if income
      redirect_to :action=>'income_list'
    else
      redirect_to :action=>'expense_list'
    end


  end

  def income_list_update
    @start_date = (params[:start_date]).to_date
    @end_date = (params[:end_date]).to_date
    @incomes = FinanceTransaction.incomes(@start_date,@end_date)
  end

  def income_details
    @start_date = params[:start].to_date
    @end_date = params[:end].to_date
    @income_category = FinanceTransactionCategory.find(params[:id])
    @incomes = @income_category.finance_transactions.find(:all,:conditions => ["transaction_date >= '#{@start_date}' and transaction_date <= '#{@end_date}'"])
  end

  def income_list_pdf
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    @start_date = (params[:start_date]).to_date
    @end_date = (params[:end_date]).to_date
    @incomes = FinanceTransaction.incomes(@start_date,@end_date)
    render :pdf => 'income_list_pdf', :zoom=>0.68#, :show_as_html=>true
  end

  def income_details_pdf
    @start_date = params[:start_date].to_date
    @end_date = params[:end_date].to_date
    @income_category = FinanceTransactionCategory.find(params[:id])
    @incomes = @income_category.finance_transactions.find(:all,:conditions => ["transaction_date >= '#{@start_date}' and transaction_date <= '#{@end_date}'"])
    render :pdf => 'income_details_pdf'
  end

  def categories
    @categories = FinanceTransactionCategory.all(:conditions => {:deleted => false},:order=>'name asc')
    @fixed_categories = @categories.reject{|c|!c.is_fixed}
    @other_categories = @categories.reject{|c|c.is_fixed}
  end

  def category_new
    @finance_transaction_category = FinanceTransactionCategory.new
  end
  
  def category_create
    @finance_category = FinanceTransactionCategory.new(params[:finance_category])
    render :update do |page|
      if @finance_category.save
        @categories = FinanceTransactionCategory.all(:conditions => {:deleted => false})
        @fixed_categories = @categories.reject{|c|!c.is_fixed}
        @other_categories = @categories.reject{|c|c.is_fixed}
        page.replace_html 'form-errors', :text => ''
        page << "Modalbox.hide();"
        page.replace_html 'category-list', :partial => 'category_list'
        page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg35')}</p>"

      else
        page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @finance_category
        page.visual_effect(:highlight, 'form-errors')
      end
    end
  end

  def category_delete
    @finance_category = FinanceTransactionCategory.find(params[:id])
    @finance_category.update_attributes(:deleted => true)
    @categories = FinanceTransactionCategory.all(:conditions => {:deleted => false})
    @fixed_categories = @categories.reject{|c|!c.is_fixed}
    @other_categories = @categories.reject{|c|c.is_fixed}
  end

  def category_edit
    @finance_category = FinanceTransactionCategory.find(params[:id])
    @categories = FinanceTransactionCategory.all(:conditions => {:deleted => false})
  end

  def category_update
    @finance_category = FinanceTransactionCategory.find(params[:id])
    @finance_category.update_attributes(params[:finance_category])
    @categories = FinanceTransactionCategory.all(:conditions => {:deleted => false})
    @fixed_categories = @categories.reject{|c|!c.is_fixed}
    @other_categories = @categories.reject{|c|c.is_fixed}
  end

  def transaction_trigger_create
    @trigger = FinanceTransactionTrigger.new(params[:transaction_trigger])    
    render :update do |page|
      if @trigger.save
        @triggers = FinanceTransactionTrigger.all
        page.replace_html 'transaction-triggers-list', :partial => 'transaction_triggers_list'
        page.replace_html 'form-errors', :text => ''
        page << "Modalbox.hide();"
        page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg17')}</p>"

      else
        page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @trigger
        page.visual_effect(:highlight, 'form-errors')
      end
    end
  end

                
            

  def transaction_trigger_edit
    @cat_names = ["'Fee'","'Salary'"]
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      @cat_names << "'#{category[:category_name]}'"
    end
    @transaction_trigger = FinanceTransactionTrigger.find(params[:id])
    @categories = FinanceTransactionCategory.find(:all ,:conditions => ["name NOT IN (#{@cat_names.join(',')}) and is_income=1 and deleted=0 "])
  end

  def transaction_trigger_update
    @transaction_trigger = FinanceTransactionTrigger.find(params[:id])
    render :update do |page|
      if @transaction_trigger.update_attributes(params[:transaction_trigger])
        @triggers = FinanceTransactionTrigger.all
        page.replace_html 'transaction-triggers-list', :partial => 'transaction_triggers_list'
        page.replace_html 'form-errors', :text => ''
        page << "Modalbox.hide();"
        page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg17')}</p>"

      else
        page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @transaction_trigger
        page.visual_effect(:highlight, 'form-errors')
      end
    end
  end

  def transaction_trigger_delete
    @trigger = FinanceTransactionTrigger.find(params[:id])
    @trigger.destroy
    @triggers = FinanceTransactionTrigger.all
    render :update do |page|
      page.replace_html 'transaction-triggers-list', :partial => 'transaction_triggers_list'
      page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg19')}</p>"
    end
  end

  #transaction-----------------------

  
  def update_monthly_report
    fixed_category_name
    @hr = Configuration.find_by_config_value("HR")
    @start_date = (params[:start_date]).to_date
    @end_date = (params[:end_date]).to_date
    @transactions = FinanceTransaction.find(:all,
      :order => 'transaction_date desc', :conditions => ["transaction_date >= '#{@start_date}' and transaction_date <= '#{@end_date}'"])
    #@other_transactions = FinanceTransaction.report(@start_date,@end_date,params[:page])
    @other_transaction_categories = FinanceTransaction.find(:all,params[:page], :conditions => ["transaction_date >= '#{@start_date}' and transaction_date <= '#{@end_date}'and category_id NOT IN (#{@fixed_cat_ids.join(",")})"],
      :order => 'transaction_date').map{|ft| ft.category}.uniq
    @transactions_fees = FinanceTransaction.total_fees(@start_date,@end_date)
    @salary = MonthlyPayslip.total_employees_salary(@start_date, @end_date)#Employee.total_employees_salary(employees, @start_date, @end_date)
    @donations_total = FinanceTransaction.donations_triggers(@start_date,@end_date)
    @grand_total = FinanceTransaction.grand_total(@start_date,@end_date)
    @category_transaction_totals = {}
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      @category_transaction_totals["#{category[:category_name]}"] =   FinanceTransaction.total_transaction_amount(category[:category_name],@start_date,@end_date)
    end
    @graph = open_flash_chart_object(960, 500, "graph_for_update_monthly_report?start_date=#{@start_date}&end_date=#{@end_date}")
  end
  
  def transaction_pdf
    fixed_category_name
    @hr = Configuration.find_by_config_value("HR")
    @start_date = (params[:start_date]).to_date
    @end_date = (params[:end_date]).to_date
    @transactions = FinanceTransaction.find(:all,
      :order => 'transaction_date desc', :conditions => ["transaction_date >= '#{@start_date}' and transaction_date <= '#{@end_date}'"])
    #@other_transactions = FinanceTransaction.report(@start_date,@end_date,params[:page])
    @other_transaction_categories = FinanceTransaction.find(:all,params[:page], :conditions => ["transaction_date >= '#{@start_date}' and transaction_date <= '#{@end_date}'and category_id NOT IN (#{@fixed_cat_ids.join(",")})"],
      :order => 'transaction_date').map{|ft| ft.category}.uniq
    @transactions_fees = FinanceTransaction.total_fees(@start_date,@end_date)
    @salary = MonthlyPayslip.total_employees_salary(@start_date, @end_date)[:total_salary]#Employee.total_employees_salary(employees, @start_date, @end_date)
    @donations_total = FinanceTransaction.donations_triggers(@start_date,@end_date)
    @grand_total = FinanceTransaction.grand_total(@start_date,@end_date)
    @category_transaction_totals = {}
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      @category_transaction_totals["#{category[:category_name]}"] =   FinanceTransaction.total_transaction_amount(category[:category_name],@start_date,@end_date)
    end
    render :pdf => 'transaction_pdf'
  end

  def salary_department
    month_date
    @departments = EmployeeDepartment.find(:all)
  end

  def salary_employee
    month_date
    @department = EmployeeDepartment.find(params[:id])
    @employees = @department.employees
    @payslips =  MonthlyPayslip.total_employees_salary(@start_date, @end_date, params[:id])
  end

  def employee_payslip_monthly_report
    
    @salary_date = params[:id2]
    @employee = Employee.find_in_active_or_archived(params[:id])
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    
    if params[:salary_date] == ""
      render :update do |page|
        page.replace_html "payslip_view", :text => ""
      end
      return
    end
    @monthly_payslips = MonthlyPayslip.find(:all,:conditions=>["employee_id=? AND salary_date = ?",params[:id],@salary_date],:include=>:payroll_category)
    @individual_payslips =  IndividualPayslipCategory.find(:all,:conditions=>["employee_id=? AND salary_date = ?",params[:id],@salary_date])
    @salary  = Employee.calculate_salary(@monthly_payslips, @individual_payslips)
   
  end

  def donations_report
    month_date
    category_id = FinanceTransactionCategory.find_by_name("Donation").id
    @donations = FinanceTransaction.find(:all,:order => 'transaction_date desc', :conditions => ["transaction_date >= '#{@start_date}' and transaction_date <= '#{@end_date}'and category_id ='#{category_id}'"])
    
  end

  def fees_report
    month_date
    fees_id = FinanceTransactionCategory.find_by_name('Fee').id
    @fee_collection = FinanceFeeCollection.find(:all,:joins=>"INNER JOIN finance_fees ON finance_fees.fee_collection_id = finance_fee_collections.id INNER JOIN finance_transactions ON finance_transactions.finance_id = finance_fees.id AND finance_transactions.transaction_date >= '#{@start_date}' AND finance_transactions.transaction_date <= '#{@end_date}' AND finance_transactions.category_id = #{fees_id}",:group=>"finance_fee_collections.id")
    
  end

  def batch_fees_report
    month_date
    @fee_collection = FinanceFeeCollection.find(params[:id])
    @batch = @fee_collection.batch
    @transaction = @fee_collection.finance_transactions.all(:conditions=>"transaction_date >= '#{@start_date}' AND transaction_date <= '#{@end_date}'")
  end

  def student_fees_structure
    
    month_date
    @student = Student.find(params[:id])
    @components = @student.get_fee_strucure_elements
    
  end

  # approve montly payslip ----------------------

  def approve_monthly_payslip
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
    dates = MonthlyPayslip.find_all_by_salary_date(Date.parse(params[:date]), :conditions=>["is_rejected is false"])

    dates.each do |d|
      d.approve(current_user.id,"Approved")
    end

    emp_ids = dates.map{|date| date.employee_id }.uniq.join(',')
    Delayed::Job.enqueue(PayslipTransactionJob.new(
        :salary_date => params[:date],
        :employee_id => emp_ids
      ))

    flash[:notice] = "#{t('flash8')}"
    redirect_to :action => "index"

    
  end

  def employee_payslip_approve
    dates = MonthlyPayslip.find_all_by_salary_date_and_employee_id(Date.parse(params[:id2]),params[:id])
    dates.each do |d|
      d.approve(current_user.id,params[:payslip_accept][:remark])
    end
    Delayed::Job.enqueue(PayslipTransactionJob.new(
        :salary_date => params[:id2],
        :employee_id => params[:id]
      ))
    flash[:notice] = "#{t('flash8')}"
    render :update do |page|
      page.reload
    end
  end
  def employee_payslip_reject
    dates = MonthlyPayslip.find_all_by_salary_date_and_employee_id(Date.parse(params[:id2]),params[:id])
    employee = Employee.find(params[:id])

    dates.each do |d|
      d.reject(current_user.id, params[:payslip_reject][:reason])
    end
    privilege = Privilege.find_by_name("PayslipPowers")
    hr_ids = privilege.user_ids
    subject = "#{t('payslip_rejected')}"
    body = "#{t('payslip_rejected_for')} "+ employee.first_name+" "+ employee.last_name+ " (#{t('employee_number')} : #{employee.employee_number})" +" #{t('for_the_month')} #{params[:id2].to_date.strftime("%B %Y")}"
    Delayed::Job.enqueue(DelayedReminderJob.new( :sender_id  => current_user.id,
        :recipient_ids => hr_ids,
        :subject=>subject,
        :body=>body ))
    render :update do |page|
      page.reload
    end
  end

  def employee_payslip_accept_form
    @id1 = params[:id]
    @id2 = params[:id2]
    respond_to do |format|
      format.js { render :action => 'accept' }
    end
  end

  def employee_payslip_reject_form
    @id1 = params[:id]
    @id2 = params[:id2]
    respond_to do |format|
      format.js { render :action => 'reject' }
    end
  end

  #view monthly payslip -------------------------------
  def view_monthly_payslip
    
    @departments = EmployeeDepartment.find(:all, :conditions=>"status = true", :order=> "name ASC")
    @salary_dates = MonthlyPayslip.find(:all,:select => "distinct salary_date")
    if request.post?
      post_data = params[:payslip]
      unless post_data.blank?
        if post_data[:salary_date].present? and post_data[:department_id].present?
          @payslips = MonthlyPayslip.find_and_filter_by_department(post_data[:salary_date],post_data[:department_id])
        else
          flash[:notice] = "#{t('select_salary_date')}"
          redirect_to :action=>"view_monthly_payslip"
        end
      end
    end
  end


  def view_employee_payslip
    @monthly_payslips = MonthlyPayslip.find(:all,:conditions=>["employee_id=? AND salary_date = ?",params[:id],params[:salary_date]],:include=>:payroll_category)
    @individual_payslips =  IndividualPayslipCategory.find(:all,:conditions=>["employee_id=? AND salary_date = ?",params[:id],params[:salary_date]])
    @salary  = Employee.calculate_salary(@monthly_payslips, @individual_payslips)
    @currency_type= Configuration.find_by_config_key("CurrencyType").config_value
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
                       OR employee_number LIKE ? OR (concat(first_name, \" \", last_name) LIKE ?))" + other_conditions,
          "#{params[:query]}%","#{params[:query]}%","#{params[:query]}%",
          "#{params[:query]}", "#{params[:query]}"],
        :order => "first_name asc") unless params[:query] == ''
    else
      @employee = Employee.find(:all,
        :conditions => ["(employee_number LIKE ?)" + other_conditions,"#{params[:query]}%"],
        :order => "first_name asc") unless params[:query] == ''
    end
    render :layout => false
  end

  #asset-liability-----------

  def create_liability
    @liability = Liability.new(params[:liability])
    render :update do |page|
      if @liability.save
        page.replace_html 'form-errors', :text => ''
        page << "Modalbox.hide();"
        page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg23')}</p>"
      else
        page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @liability
        page.visual_effect(:highlight, 'form-errors')
      end
    end
    
  end

  def edit_liability
    @liability = Liability.find(params[:id])
  end

  def update_liability
    @liability = Liability.find(params[:id])
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    
    render :update do |page|
      if @liability.update_attributes(params[:liability])
        @liabilities = Liability.find(:all,:conditions => 'is_deleted = 0')
        page.replace_html "liability_list", :partial => "liability_list"
        page << "Modalbox.hide();"
        page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg24')}</p>"
      else
        page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @liability
        page.visual_effect(:highlight, 'form-errors')
      end
    end
  end

  def view_liability
    @liabilities = Liability.find(:all,:conditions => 'is_deleted = 0')
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
  end
  
  def liability_pdf
    @liabilities = Liability.find(:all,:conditions => 'is_deleted = 0')
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    render :pdf => 'liability_report_pdf'
  end

  def delete_liability
    @liability = Liability.find(params[:id])
    @liability.update_attributes(:is_deleted => true)
    @liabilities = Liability.find(:all ,:conditions => 'is_deleted = 0')
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    render :update do |page|
      page.replace_html "liability_list", :partial => "liability_list"
      page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg25')}</p>"
    end
  end

  def each_liability_view
    @liability = Liability.find(params[:id])
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
  end

  def create_asset
    @asset = Asset.new(params[:asset])
    render :update do |page|
      if @asset.save
        page.replace_html 'form-errors', :text => ''
        page << "Modalbox.hide();"
        page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg20')}</p>"

      else
        page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @asset
        page.visual_effect(:highlight, 'form-errors')
      end
    end
  end

  def view_asset
    @assets = Asset.find(:all,:conditions => 'is_deleted = 0')
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
  end

  def asset_pdf
    @assets = Asset.find(:all,:conditions => 'is_deleted = 0')
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    render :pdf => 'asset_report_pdf'
  end

  def edit_asset
    @asset = Asset.find(params[:id])
  end

  def update_asset
    @asset = Asset.find(params[:id])
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    
    render :update do |page|
      if @asset.update_attributes(params[:asset])
        @assets = Asset.find(:all,:conditions => 'is_deleted = 0')
        page.replace_html "asset_list", :partial => "asset_list"
        page << "Modalbox.hide();"
        page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg21')}</p>"
      else
        page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @asset
        page.visual_effect(:highlight, 'form-errors')
      end
    end
  end

  def delete_asset
    @asset = Asset.find(params[:id])
    @asset.update_attributes(:is_deleted => true)
    @assets = Asset.all(:conditions => 'is_deleted = 0')
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    render :update do |page|
      page.replace_html "asset_list", :partial => "asset_list"
      page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg22')}</p>"
    end
  end

  def each_asset_view
    @asset = Asset.find(params[:id])
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
  end
  #fees ----------------

  def master_fees
    @finance_fee_category = FinanceFeeCategory.new
    @finance_fee_particular = FinanceFeeParticular.new
    @batchs = Batch.active
    @master_categories = FinanceFeeCategory.find(:all,:conditions=> ["is_deleted = '#{false}' and is_master = 1 and batch_id=?",params[:batch_id]]) unless params[:batch_id].blank?
    @student_categories = StudentCategory.active
  end
  
  def master_category_new
    @finance_fee_category = FinanceFeeCategory.new
    @batches = Batch.active
    respond_to do |format|
      format.js { render :action => 'master_category_new' }
    end
  end

  def master_category_create
    if request.post?
      @batches = params[:finance_fee_category][:batch_id]
      unless @batches.nil?
        unless @batches.empty?
          @batches.each do |b|
            @finance_fee_category = FinanceFeeCategory.new()
            @finance_fee_category.name = params[:finance_fee_category][:name]
            @finance_fee_category.description = params[:finance_fee_category][:description]
            @finance_fee_category.batch_id = b
            @finance_fee_category.is_master = true
            unless @finance_fee_category.save
              @error = true
            end
          end
        end
      else
        @finance_fee_category = FinanceFeeCategory.new(params[:finance_fee_category])
        @finance_fee_category.valid?
        @error = true
      end
      @master_categories = FinanceFeeCategory.find(:all,:conditions=> ["is_deleted = '#{false}' and is_master = 1"])
      respond_to do |format|
        format.js { render :action => 'master_category_create' }
      end
    end
  end
 
  def master_category_edit
    @finance_fee_category = FinanceFeeCategory.find(params[:id])
    respond_to do |format|
      format.js { render :action => 'master_category_edit' }
    end
  end

  def master_category_update
    @finance_fee_category = FinanceFeeCategory.find(params[:id])
    render :update do |page|
      if @finance_fee_category.update_attributes(params[:finance_fee_category])
        @master_categories = FinanceFeeCategory.find(:all, :conditions =>["is_deleted = '#{false}' and is_master = 1 and batch_id = #{@finance_fee_category.batch_id}"])
        page.replace_html 'form-errors', :text => ''
        page << "Modalbox.hide();"
        page.replace_html 'categories', :partial => 'master_category_list'
        page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg13')}</p>"
      else
        page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @finance_fee_category
        page.visual_effect(:highlight, 'form-errors')
      end
    end
  end

  def master_category_particulars
    @finance_fee_category = FinanceFeeCategory.find(params[:id])
    @particulars = FinanceFeeParticular.paginate(:page => params[:page],:conditions => ["is_deleted = '#{false}' and finance_fee_category_id = '#{@finance_fee_category.id}' "])
  end
  def master_category_particulars_edit
    @finance_fee_particular= FinanceFeeParticular.find(params[:id])
    @student_categories = StudentCategory.active
    respond_to do |format|
      format.js { render :action => 'master_category_particulars_edit' }
    end
  end

  def master_category_particulars_update
    @feeparticulars = FinanceFeeParticular.find( params[:id])
    render :update do |page|
      if @feeparticulars.update_attributes(params[:finance_fee_particular])
        @finance_fee_category = FinanceFeeCategory.find(@feeparticulars.finance_fee_category_id)
        @particulars = FinanceFeeParticular.paginate(:page => params[:page],:conditions => ["is_deleted = '#{false}' and finance_fee_category_id = '#{@finance_fee_category.id}' "])
        page.replace_html 'form-errors', :text => ''
        page << "Modalbox.hide();"
        page.replace_html 'categories', :partial => 'master_particulars_list'
        page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg14')}</p>"
      else
        page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @feeparticulars
        page.visual_effect(:highlight, 'form-errors')
      end
    end
    #    respond_to do |format|
    #      format.js { render :action => 'master_category_particulars' }
    #    end
  end
  def master_category_particulars_delete
    @feeparticulars = FinanceFeeParticular.find( params[:id])
    @feeparticulars.update_attributes(:is_deleted => true )
    @finance_fee_category = FinanceFeeCategory.find(@feeparticulars.finance_fee_category_id)
    @particulars = FinanceFeeParticular.paginate(:page => params[:page],:conditions => ["is_deleted = '#{false}' and finance_fee_category_id = '#{@finance_fee_category.id}' "])
    respond_to do |format|
      format.js { render :action => 'master_category_particulars' }
    end
  end
  def master_category_delete
    @finance_fee_category = FinanceFeeCategory.find(params[:id])
    @finance_fee_category.update_attributes(:is_deleted => true)
    @finance_fee_category.delete_particulars
    @master_categories = FinanceFeeCategory.find(:all, :conditions =>["is_deleted = '#{false}' and is_master = 1 and batch_id = #{@finance_fee_category.batch_id}"])
    respond_to do |format|
      format.js { render :action => 'master_category_delete' }
    end
  end

  def show_master_categories_list
    unless params[:id].nil?
      @finance_fee_category = FinanceFeeCategory.new
      @finance_fee_particular = FinanceFeeParticular.new
      @batches = Batch.find params[:id] unless params[:id] == ""
      @master_categories = FinanceFeeCategory.find(:all,:conditions=> ["is_deleted = '#{false}' and is_master = 1 and batch_id=?",params[:id]])
      @student_categories = StudentCategory.active

      render :update do |page|
        page.replace_html 'categories', :partial => 'master_category_list'
      end
    end
  end

  def fees_particulars_new
    @fees_categories = FinanceFeeCategory.find(:all ,:conditions=> "is_deleted = 0 and is_master = 1", :order=>"name ASC")
    @fees_categories.reject!{|f|f.batch.is_deleted or !f.batch.is_active }
    @student_categories = StudentCategory.active
  end

  def fees_particulars_create
    @error = false
    finance_fee_categories = FinanceFeeCategory.find_all_by_id(params[:finance_fee_particular][:finance_fee_category_ids].reject{|cat| cat.empty?}.map{|cat| cat.to_i}) unless params[:finance_fee_particular][:finance_fee_category_ids].blank?
    unless finance_fee_categories.blank?
      batches = finance_fee_categories.map{|ffc| ffc.batch}
      posted_params = params[:finance_fee_particular]
      posted_admission_no = params[:finance_fee_particular][:admission_no]
      posted_params.delete("finance_fee_category_ids")
      finance_fee_categories.each do |ffc|
        @finance_fee_particular = ffc.fee_particulars.new(posted_params)
        if params[:particulars][:select].to_s == 'student'
          unless posted_admission_no.empty?
            all_admission_no = admission_no = posted_admission_no.split(",")
            posted_params.delete "admission_no"
            all_students = batches.map{|batch| batch.students.map{|stu| stu.admission_no}}.flatten
            rejected_admission_no = admission_no.select{|adm| !all_students.include? adm}
            unless (rejected_admission_no.empty?)
              @error = true
              @finance_fee_particular.errors.add_to_base("#{rejected_admission_no.join(',')} #{t('does_not_belong_to_batch')} #{batches.map{|batch| batch.full_name}.join(',')}")
            end
            selected_admission_no = all_admission_no.select{|adm| ffc.batch.students.all.map{|stu| stu.admission_no}.include? adm}
            selected_admission_no.each do |a|
              s = Student.find_by_admission_no(a)
              if s.nil?
                @error = true
                @finance_fee_particular.errors.add_to_base("#{a} #{t('does_not_exist')}")
              end
            end
            unless @error
              selected_admission_no.each do |a|
                posted_params["admission_no"] = a.to_s
                @error = true unless @finance_fee_particular = ffc.fee_particulars.create(posted_params)
              end
            end
          else
            @error = true
            @finance_fee_particular.errors.add(:admission_no,"#{t('is_blank')}")
          end
        else
          @error = true unless @finance_fee_particular.save
        end
      end
      @particulars = FinanceFeeParticular.all(:conditions => {:is_deleted => false,:finance_fee_category_id => finance_fee_categories.map{|ffc| ffc.id}})
      if @error.blank?
        flash[:notice] = t('particulars_created_successfully')
      else
        @fees_categories = FinanceFeeCategory.find(:all ,:conditions=> "is_deleted = 0 and is_master = 1")
        @fees_categories.reject!{|f|f.batch.is_deleted or !f.batch.is_active }
        render :action => 'fees_particulars_new'
        return
      end
    else
      flash[:notice] = t('select_fee_category')
    end
    redirect_to :action => "fees_particulars_new"
  end

  def fees_particulars_new2
    @fees_category = FinanceFeeCategory.find(params[:category_id])
    @student_categories = StudentCategory.active
    respond_to do |format|
      format.js { render :action => 'fees_particulars_new2' }
    end
  end

  def fees_particulars_create2
    @error = false
    finance_fee_categories = FinanceFeeCategory.find_all_by_id(params[:finance_fee_particular][:finance_fee_category_ids].reject{|cat| cat.empty?}.map{|cat| cat.to_i}) unless params[:finance_fee_particular][:finance_fee_category_ids].blank?
    batches = finance_fee_categories.map{|ffc| ffc.batch}
    posted_params = params[:finance_fee_particular]
    posted_admission_no = params[:finance_fee_particular][:admission_no]
    posted_params.delete("finance_fee_category_ids")
    finance_fee_categories.each do |ffc|
      @finance_fee_particular = ffc.fee_particulars.new(posted_params)
      if params[:particulars][:select].to_s == 'student'
        unless posted_admission_no.empty?
          all_admission_no = admission_no = posted_admission_no.split(",")
          posted_params.delete "admission_no"
          all_students = batches.map{|batch| batch.students.map{|stu| stu.admission_no}}.flatten
          rejected_admission_no = admission_no.select{|adm| !all_students.include? adm}
          unless (rejected_admission_no.empty?)
            @error = true
            @finance_fee_particular.errors.add_to_base("#{rejected_admission_no.join(',')} #{t('does_not_belong_to_batch')} #{batches.map{|batch| batch.full_name}.join(',')}")
          end
          selected_admission_no = all_admission_no.select{|adm| ffc.batch.students.all.map{|stu| stu.admission_no}.include? adm}
          selected_admission_no.each do |a|
            s = Student.find_by_admission_no(a)
            if s.nil?
              @error = true
              @finance_fee_particular.errors.add_to_base("#{a} #{t('does_not_exist')}")
            end
          end
          unless @error
            selected_admission_no.each do |a|
              posted_params["admission_no"] = a.to_s
              @error = true unless @finance_fee_particular = ffc.fee_particulars.create(posted_params)
            end
          end
        else
          @error = true
          @finance_fee_particular.errors.add(:admission_no,"#{t('is_blank')}")
        end
      else
        @error = true unless @finance_fee_particular.save
      end
    end
    @particulars = FinanceFeeParticular.all(:conditions => {:is_deleted => false,:finance_fee_category_id => finance_fee_categories.map{|ffc| ffc.id}})
  end


  def additional_fees_create_form
    @batches = Batch.active
    @student_categories = StudentCategory.active
  end
  
  def additional_fees_create

    batch = params[:additional_fees][:batch_id] unless params[:additional_fees][:batch_id].nil?
    # batch ||=[]
    @batches = Batch.active
    @user = current_user
    @students = Student.find_all_by_batch_id(batch) unless batch.nil?
    @additional_category = FinanceFeeCategory.new(
      :name => params[:additional_fees][:name],
      :description => params[:additional_fees][:description],
      :batch_id => params[:additional_fees][:batch_id]
    )
    if params[:additional_fees][:due_date].to_date >= params[:additional_fees][:end_date].to_date
      if @additional_category.save && params[:additional_fees][:start_date].strip.length!=0 && params[:additional_fees][:due_date].strip.length!=0 && params[:additional_fees][:end_date].strip.length!=0
        @collection_date = FinanceFeeCollection.create(
          :name => @additional_category.name,
          :start_date => params[:additional_fees][:start_date],
          :end_date => params[:additional_fees][:end_date],
          :due_date => params[:additional_fees][:due_date],
          :batch_id => params[:additional_fees][:batch_id],
          :fee_category_id => @additional_category.id
        )
        body = "<p>#{t('fee_submission_date_for')} "+@additional_category.name+" #{t('has_been_published')} <br />
                               #{t('fees_submiting_date_starts_on')}< br />
                               #{t('start_date')} : "+@collection_date.start_date.to_s+" <br />"+
          "#{t('end_date')} : "+@collection_date.end_date.to_s+" <br />"+
          "#{t('due_date')} : "+@collection_date.due_date.to_s
        subject = "#{t('fees_submission_date')}"
        @due_date = @collection_date.due_date.strftime("%Y-%b-%d") +  " 00:00:00"
        unless batch.empty?
          @students.each do |s|
            FinanceFee.create(:student_id => s.id,:fee_collection_id => @collection_date.id)
            Reminder.create(:sender=>@user.id, :recipient=>s.id, :subject=> subject,
              :body => body, :is_read=>false, :is_deleted_by_sender=>false,:is_deleted_by_recipient=>false)
          end
          Event.create(:title=> "#{t('fees_due')}", :description =>@additional_category.name, :start_date => @due_date.to_datetime, :end_date => @due_date.to_datetime, :is_due => true, :origin => @collection_date)
        else
          @batches.each do |b|
            @students = Student.find_all_by_batch_id(b.id)
            @students.each do |s|
              FinanceFee.create(:student_id => s.id,:fee_collection_id => @collection_date.id)
              Reminder.create(:sender=>@user.id, :recipient=>s.user.id, :subject=> subject,
                :body => body, :is_read=>false, :is_deleted_by_sender=>false,:is_deleted_by_recipient=>false)
            end
          end
          Event.create(:title=> "#{t('fees_due')}", :description =>@additional_category.name, :start_date => @due_date.to_datetime, :end_date => @due_date.to_datetime, :is_due => true, :origin => @collection_date)
        end
        flash[:notice] = "#{t('flash9')}"
        redirect_to(:action => "add_particulars" ,:id => @collection_date.id)
      else
        flash[:notice] = "#{t('flash10')}"
        redirect_to :action => "additional_fees_create_form"
      end
    else
      flash[:notice] = "#{t('flash11')}"
      redirect_to :action => "additional_fees_create_form"
    end
  end

  def additional_fees_edit
    @finance_fee_category = FinanceFeeCategory.find(params[:id])
    @collection_date = FinanceFeeCollection.find_by_fee_category_id(@finance_fee_category.id)
    respond_to do |format|
      format.js { render :action => 'additional_fees_edit' }
    end
    flash[:notice] = "#{t('flash26')}"
  end

  def additional_fees_update
    @finance_fee_category = FinanceFeeCategory.find(params[:id])
    @collection_date = FinanceFeeCollection.find_by_fee_category_id(@finance_fee_category.id)
    #    render :update do |page|

    if @finance_fee_category.update_attributes(:name =>params[:finance_fee_category][:name], :description =>params[:finance_fee_category][:description])
      if @collection_date.update_attributes(:start_date=>params[:additional_fees][:start_date], :end_date=>params[:additional_fees][:end_date],:due_date=>params[:additional_fees][:due_date])
        @collection_date.event.update_attributes(:start_date=>@collection_date.due_date.to_datetime, :end_date=>@collection_date.due_date.to_datetime)
        @additional_categories = FinanceFeeCategory.find(:all, :conditions =>["is_deleted = '#{false}' and is_master = '#{false}' and batch_id = '#{@finance_fee_category.batch_id}'"])
        #        page.replace_html 'form-errors', :text => ''
        #        page << "Modalbox.hide();"
        #        page.replace_html 'particulars', :partial => 'additional_fees_list'
        #        end
      else
        @error = true
      end
    else
      #        page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @finance_fee_category
      #        page.visual_effect(:highlight, 'form-errors')
      @error = true
    end
    #    end
  end

  def additional_fees_delete
    @finance_fee_category = FinanceFeeCategory.find(params[:id])
    @finance_fee_category.update_attributes(:is_deleted => true)
    @finance_fee_collection = FinanceFeeCollection.find_by_fee_category_id(params[:id])
    @finance_fee_collection.update_attributes(:is_deleted => true)
    @finance_fee_category.delete_particulars
    # redirect_to :action => "additional_fees_list"
    @additional_categories = FinanceFeeCategory.find(:all, :conditions =>["is_deleted = '#{false}' and is_master = '#{false}' and batch_id = '#{@finance_fee_category.batch_id}'"])
    respond_to do |format|
      format.js { render :action => 'additional_fees_delete' }
      flash[:notice] = "#{t('flash27')}"
    end
  end

  def add_particulars
    @collection_date = FinanceFeeCollection.find(params[:id])
    @additional_category = FinanceFeeCategory.find(@collection_date.fee_category_id)
    @student_categories = StudentCategory.active
    @finance_fee_particulars = FeeCollectionParticular.new
    @finance_fee_particulars_list = FeeCollectionParticular.find(:all,:conditions => ["is_deleted = '#{false}' and finance_fee_collection_id = '#{@collection_date.id}'"])
  end

  def add_particulars_new
    @collection_date = FinanceFeeCollection.find(params[:id])
    @additional_category = FinanceFeeCategory.find(@collection_date.fee_category_id)
    @student_categories = StudentCategory.active
    @finance_fee_particulars = FeeCollectionParticular.new
  end

  def add_particulars_create
    @collection_date = FinanceFeeCollection.find(params[:id])
    @additional_category = FinanceFeeCategory.find(@collection_date.fee_category_id)
    @error = false
    unless params[:finance_fee_particulars][:admission_no].nil?
      unless params[:finance_fee_particulars][:admission_no].empty?
        posted_params = params[:finance_fee_particulars]
        admission_no = posted_params[:admission_no].split(",")
        posted_params.delete "admission_no"
        err = ""
        admission_no.each do |a|
          posted_params["admission_no"] = a.to_s
          @finance_fee_particulars = FeeCollectionParticular.new(posted_params)
          @finance_fee_particulars.finance_fee_collection_id = @collection_date.id
          s = Student.find_by_admission_no(a)
          unless s.nil?
            if (s.batch_id == @collection_date.batch_id) or (@collection_date.batch_id.nil?)
              unless @finance_fee_particulars.save
                @error = true
              end
            else
              @error = true
              err = err + "#{a}#{t('does_not_belong_to_batch')} #{@collection_date.batch.full_name}. <br />"
            end
          else
            @error = true
            err = err + "#{a} #{t('does_not_exist')}<br />"
          end
        end
        @finance_fee_particulars.errors.add(:admission_no," #{t('invalid')} : <br />" + err) if @error==true
        @finance_fee_particulars_list = FeeCollectionParticular.find(:all,:conditions => ["is_deleted = '#{false}' and finance_fee_collection_id = '#{@collection_date.id}'"])  unless @error== true
      else
        @error = true
        @finance_fee_particulars = FeeCollectionParticular.new(params[:finance_fee_particulars])
        @finance_fee_particulars.valid?
        @finance_fee_particulars.errors.add(:admission_no,"#{t('is_blank')}")
      end
    else
      @finance_fee_particulars = FeeCollectionParticular.new(params[:finance_fee_particulars])
      @finance_fee_particulars.finance_fee_collection_id = @collection_date.id
      unless @finance_fee_particulars.save
        @error = true
      else
        @finance_fee_particulars_list = FeeCollectionParticular.find(:all,:conditions => ["is_deleted = '#{false}' and finance_fee_collection_id = '#{@collection_date.id}'"])
      end

    end
  end

  def student_or_student_category
    @student_categories = StudentCategory.active
    
    select_value = params[:select_value]

    if select_value == "category"
      render :update do |page|
        page.replace_html "student", :partial => "student_category_particulars"
      end
    elsif select_value == "student"
      render :update do |page|
        page.replace_html "student", :partial => "student_admission_particulars"
      end
    elsif select_value == "all"
      render :update do |page|
        page.replace_html "student", :text=>""
      end
    end
  end

  def additional_fees_list
    @batchs=Batch.active
    #@additional_categories = FinanceFeeCategory.paginate(:page => params[:page],:conditions => ["is_deleted = '#{false}' and is_master = '#{false}'"])
  end

  def show_additional_fees_list
    @additional_categories = FinanceFeeCategory.find(:all,:conditions => ["is_deleted = '#{false}' and is_master = '#{false}' and batch_id=?",params[:id]])
    render :update do |page|
      page.replace_html 'particulars', :partial =>'additional_fees_list'
    end
  end

  def additional_particulars
    @additional_category = FinanceFeeCategory.find(params[:id])
    @collection_date = FinanceFeeCollection.find_by_fee_category_id(@additional_category.id)
    @particulars = FeeCollectionParticular.find(:all,:conditions => ["is_deleted = '#{false}' and finance_fee_collection_id = '#{@collection_date.id}' "])
  end

  def add_particulars_edit
    @finance_fee_particulars = FeeCollectionParticular.find(params[:id])
  end
  
  def add_particulars_update
    @finance_fee_particulars = FeeCollectionParticular.find(params[:id])
    render :update do |page|
      if @finance_fee_particulars.update_attributes(params[:finance_fee_particulars])
        @collection_date = @finance_fee_particulars.finance_fee_collection
        @additional_category =@collection_date.fee_category
        @particulars = FeeCollectionParticular.paginate(:page => params[:page],:conditions => ["is_deleted = '#{false}' and finance_fee_collection_id = '#{@collection_date.id}' "])
        page.replace_html 'form-errors', :text => ''
        page << "Modalbox.hide();"
        page.replace_html 'particulars', :partial => 'additional_particulars_list'
        page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('flash_msg32')}</p>"
      else
        page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @finance_fee_particulars
        page.visual_effect(:highlight, 'form-errors')
      end
    end
  end

  def add_particulars_delete
    @finance_fee_particulars = FeeCollectionParticular.find(params[:id])
    @finance_fee_particulars.update_attributes(:is_deleted => true)
    @collection_date = @finance_fee_particulars.finance_fee_collection
    @additional_category =@collection_date.fee_category
    @particulars = FeeCollectionParticular.paginate(:page => params[:page],:conditions => ["is_deleted = '#{false}' and finance_fee_collection_id = '#{@collection_date.id}' "])
    render :update do |page|
      page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('particulars_deleted_successfully')}</p>"
      page.replace_html 'particulars', :partial => 'additional_particulars_list'
    end
  end

  def fee_collection_batch_update
    @fee_category = FinanceFeeCategory.find_all_by_name(params[:id], :conditions=>['is_deleted is false'])
    @fee_category.reject!{|x| x.batch.students.blank? or x.batch.is_deleted? or x.fee_particulars.blank?}
    render :update do |page|
      page.replace_html "batchs" ,:partial => "fee_collection_batchs"
    end
  end

  def fee_collection_new
    @fee_categories = FinanceFeeCategory.common_active
    @finance_fee_collection = FinanceFeeCollection.new
  end

  def fee_collection_create
    @user = current_user
    @fee_categories = FinanceFeeCategory.common_active
    unless params[:finance_fee_collection].nil?
      fee_category_name = params[:finance_fee_collection][:fee_category_id]
      @fee_category = FinanceFeeCategory.find_all_by_name(fee_category_name, :conditions=>['is_deleted is false'])
      @fee_category.reject!{|x| x.batch.students.blank? or x.batch.is_deleted? or x.fee_particulars.blank?}
    end
    category =[]
    @finance_fee_collection = FinanceFeeCollection.new
    if request.post?
      unless params[:fee_collection].nil?
        category = params[:fee_collection][:category_ids]
        subject = "#{t('fees_submission_date')}"

        category.each do |c|
          fee_category = FinanceFeeCategory.find_by_id(c)
          b = Batch.find_by_id(fee_category.batch_id)
          @finance_fee_collection = FinanceFeeCollection.new(
            :name => params[:finance_fee_collection][:name],
            :start_date => params[:finance_fee_collection][:start_date],
            :end_date => params[:finance_fee_collection][:end_date],
            :due_date => params[:finance_fee_collection][:due_date],
            :fee_category_id => c,
            :batch_id => b.id
          )
          if @finance_fee_collection.save
            @students = Student.find_all_by_batch_id(b.id)
            unless fee_category.have_common_particular?
              @students = @students.select{|stu| stu.has_associated_fee_particular?(fee_category)}
            end
            body = "<p><b>#{t('fee_submission_date_for')} <i>"+fee_category_name+"</i> #{t('has_been_published')} </b>
              \n \n  #{t('start_date')} : "+@finance_fee_collection.start_date.to_s+" \n"+
              " #{t('end_date')} :"+@finance_fee_collection.end_date.to_s+" \n "+
              " #{t('due_date')} :"+@finance_fee_collection.due_date.to_s+" \n \n \n "+
              " #{t('check_your')}  #{t('fee_structure')}"
            recipient_ids = []
            @students.each do |s|
              unless s.has_paid_fees
                FinanceFee.create(:student_id => s.id,:fee_collection_id => @finance_fee_collection.id)
                recipient_ids << s.user.id
              end
            end
            new_event =  Event.create(:title=> "#{t('fees_due')}", :description =>params[:finance_fee_collection][:name], :start_date => @finance_fee_collection.due_date.to_datetime, :end_date => @finance_fee_collection.due_date.to_datetime, :is_due => true , :origin=>@finance_fee_collection)
            BatchEvent.create(:event_id => new_event.id, :batch_id => b.id )
            Delayed::Job.enqueue(DelayedReminderJob.new( :sender_id  => @user.id,
                :recipient_ids => recipient_ids,
                :subject=>subject,
                :body=>body ))
          else
            @error = true
          end
        end
      else
        @error = true
        if params[:finance_fee_collection].present?
          @finance_fee_collection = FinanceFeeCollection.new(
            :name => params[:finance_fee_collection][:name],
            :start_date => params[:finance_fee_collection][:start_date],
            :end_date => params[:finance_fee_collection][:end_date],
            :due_date => params[:finance_fee_collection][:due_date],
            :fee_category_id => nil,
            :batch_id => nil
          )
        end
        @finance_fee_collection.errors.add_to_base("#{t('fees_category_cant_be_blank')}")
      end

      if @error.nil?
        flash[:notice] = t('flash_msg33')
        redirect_to :action => 'fee_collection_new'
      else
        render :action => 'fee_collection_new'
      end
    else
      redirect_to :action => 'fee_collection_new'
    end
  end

  def fee_collection_view
    @batchs = Batch.active
  end

  def fee_collection_dates_batch
    @batch= Batch.find(params[:id])
    @finance_fee_collections = @batch.fee_collection_dates
    render :update do |page|
      page.replace_html 'fee_collection_dates', :partial => 'fee_collection_dates_batch'
    end
  end

  def fee_collection_edit
    @finance_fee_collection = FinanceFeeCollection.find params[:id]
  end

  
  def fee_collection_update
    @user = current_user
    @finance_fee_collection = FinanceFeeCollection.find params[:id]
    events = @finance_fee_collection.event
    render :update do |page|
      if params[:finance_fee_collection][:due_date].to_date >= params[:finance_fee_collection][:end_date].to_date
        if @finance_fee_collection.update_attributes(params[:finance_fee_collection])
          events.update_attributes(:start_date=> @finance_fee_collection.due_date.to_datetime, :end_date=> @finance_fee_collection.due_date.to_datetime, :description=>params[:finance_fee_collection][:name]) unless events.blank?
          fee_category_name = @finance_fee_collection.fee_category.name
          subject = "#{t('fees_submission_date')}"
          body = "<p><b>#{t('fee_submission_date_for')} <i>"+fee_category_name+"</i> #{t('has_been_updated')}</b> <br /><br/>
                                #{t('start_date')} : "+@finance_fee_collection.start_date.to_s+"<br />"+
            " #{t('end_date')} : "+@finance_fee_collection.end_date.to_s+" <br />"+
            " #{t('due_date')} : "+@finance_fee_collection.due_date.to_s+" <br /><br /><br />"+
            " #{t('check_your')} #{t('fee_structure')} <br/><br/><br/> "
          recipient_ids = []
          @students = Student.find_all_by_batch_id(@finance_fee_collection.batch_id)
          @students.each do |s|
            unless s.has_paid_fees
              recipient_ids << s.user.id
            end
          end
          Delayed::Job.enqueue(DelayedReminderJob.new( :sender_id  => @user.id,
              :recipient_ids => recipient_ids,
              :subject=>subject,
              :body=>body ))
          @finance_fee_collections = FinanceFeeCollection.all(:conditions => ["is_deleted = '#{false}' and batch_id = '#{@finance_fee_collection.batch_id}'"])
          page.replace_html 'form-errors', :text => ''
          page << "Modalbox.hide();"
          page.replace_html 'fee_collection_dates', :partial => 'fee_collection_list'
          page.replace_html 'flash_box', :text => "<p class='flash-msg'>#{t('finance.flash12')}</p>"
        else
          page.replace_html 'form-errors', :partial => 'class_timings/errors', :object => @finance_fee_collection
          page.visual_effect(:highlight, 'form-errors')
        end
      else
        page.replace_html 'form-errors', :text => "<div id='error-box'><ul><li>#{t('flash_msg15')} .</li></ul></div>"
        flash[:notice]=""
        
      end
    end
    @finance_fee_collections = FinanceFeeCollection.all(:conditions => ["is_deleted = '#{false}' and batch_id = '#{@finance_fee_collection.batch_id}'"])
  end

  def fee_collection_delete
    @finance_fee_collection = FinanceFeeCollection.find params[:id]
    @finance_fee_collection.update_attributes(:is_deleted => true)
    @finance_fee_collections = FinanceFeeCollection.all(:conditions => ["is_deleted = '#{false}' and batch_id = '#{@finance_fee_collection.batch_id}'"])
  end

  #fees_submission-----------------------------------

  def fees_submission_batch

    @batches = Batch.active
    @dates = []

  end
    
  def update_fees_collection_dates
    
    @batch = Batch.find(params[:batch_id])
    @dates = @batch.fee_collection_dates

    render :update do |page|
      page.replace_html "fees_collection_dates", :partial => "fees_collection_dates"
    end
  end

  def load_fees_submission_batch
    
    @batch   = Batch.find(params[:batch_id])
    @dates   = FinanceFeeCollection.find(:all)
    @date    =  @fee_collection = FinanceFeeCollection.find(params[:date])
    @student = Student.find(params[:student]) if params[:student]
    @fee = FinanceFee.first(:conditions=>"fee_collection_id = #{@date.id}" ,:joins=>'INNER JOIN students ON finance_fees.student_id = students.id')
    @student ||= @fee.student
    @prev_student = @student.previous_fee_student(@date.id)
    @next_student = @student.next_fee_student(@date.id)
    @financefee = @student.finance_fee_by_date @date
    @due_date = @fee_collection.due_date
    unless @financefee.transaction_id.blank?
      @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@financefee.transaction_id}\")", :order=>"created_at ASC")
    end
    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted = false"])
    @fee_particulars = @date.fees_particulars(@student)

    @batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(@date.id)
    @student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@date.id,@student.id)
    @category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@date.id,@student.student_category_id)
    @total_discount = 0
    @total_discount += @batch_discounts.map{|s| s.discount}.sum unless @batch_discounts.nil?
    @total_discount += @student_discounts.map{|s| s.discount}.sum unless @student_discounts.nil?
    @total_discount += @category_discounts.map{|s| s.discount}.sum unless @category_discounts.nil?
    if @total_discount > 100
      @total_discount = 100
    end

    render :update do |page|
      page.replace_html "student", :partial => "student_fees_submission"
    end
  end

  def update_ajax

    @batch   = Batch.find(params[:batch_id])
    @dates = FinanceFeeCollection.find(:all)
    @date = @fee_collection = FinanceFeeCollection.find(params[:date])
    @student = Student.find(params[:student]) if params[:student]
    @student ||= FinanceFee.first(:conditions=>"fee_collection_id = #{@date.id}",:joins=>'INNER JOIN students ON finance_fees.student_id = students.id').student
    @prev_student = @student.previous_fee_student(@date.id)
    @next_student = @student.next_fee_student(@date.id)
    @due_date = @fee_collection.due_date
    total_fees =0

    @financefee = @student.finance_fee_by_date @date
   
    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted IS NOT NULL"])
    @fee_particulars = @date.fees_particulars(@student)

    @batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(@fee_collection.id)
    @student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.id)
    @category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.student_category_id)
    @total_discount = 0
    @total_discount += @batch_discounts.map{|s| s.discount}.sum unless @batch_discounts.nil?
    @total_discount += @student_discounts.map{|s| s.discount}.sum unless @student_discounts.nil?
    @total_discount += @category_discounts.map{|s| s.discount}.sum unless @category_discounts.nil?
    if @total_discount > 100
      @total_discount = 100
    end
    
    @fee_particulars.each do |p|
      total_fees += p.amount
    end
    unless params[:fine].nil?
      unless @financefee.is_paid == true
        total_fees += params[:fine].to_f
      else
        total_fees = params[:fine].to_f
      end
    end
    unless params[:fees][:fees_paid].to_f < 0
      unless params[:fees][:fees_paid].to_f > params[:total_fees].to_f
        transaction = FinanceTransaction.new
        (total_fees > params[:fees][:fees_paid].to_f ) ? transaction.title = "#{t('receipt_no')}. (#{t('partial')}) F#{@financefee.id}" :  transaction.title = "#{t('receipt_no')}. F#{@financefee.id}"
        transaction.category = FinanceTransactionCategory.find_by_name("Fee")
        transaction.payee = @student
        transaction.amount = params[:fees][:fees_paid].to_f
        transaction.fine_amount = params[:fine].to_f
        transaction.fine_included = true  unless params[:fine].nil?
        transaction.finance = @financefee
        transaction.transaction_date = Date.today
        transaction.save
        unless @financefee.transaction_id.nil?
          tid =   @financefee.transaction_id + ",#{transaction.id}"
        else
          tid=transaction.id
        end

        is_paid = (params[:fees][:fees_paid].to_f == params[:total_fees].to_f) ? true : false
        @financefee.update_attributes(:transaction_id=>tid, :is_paid=>is_paid)
    
        @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{tid}\")")
      else
        @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@financefee.transaction_id}\")")
        @financefee.errors.add_to_base("#{t('flash19')}")
      end
    else
      @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@financefee.transaction_id}\")")
      @financefee.errors.add_to_base("#{t('flash23')}")
    end
    render :update do |page|
      page.replace_html "student", :partial => "student_fees_submission"
      
    end

  end

  def student_fee_receipt_pdf
    @date = @fee_collection = FinanceFeeCollection.find(params[:id2])
    @student = Student.find(params[:id])
    @financefee = @student.finance_fee_by_date @date
    @due_date = @fee_collection.due_date
    
    unless @financefee.transaction_id.blank?
      @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@financefee.transaction_id}\")", :order=>"created_at ASC")
    end
    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted = false"])
    @fee_particulars = @date.fees_particulars(@student)
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value

    @batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(@fee_collection.id)
    @student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.id)
    @category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.student_category_id)
    @total_discount = 0
    @total_discount += @batch_discounts.map{|s| s.discount}.sum unless @batch_discounts.nil?
    @total_discount += @student_discounts.map{|s| s.discount}.sum unless @student_discounts.nil?
    @total_discount += @category_discounts.map{|s| s.discount}.sum unless @category_discounts.nil?
    if @total_discount > 100
      @total_discount = 100
    end
    
    render :pdf => 'fee_receipt_pdf'
           
    #        respond_to do |format|
    #            format.pdf { render :layout => false }
    #        end

  end

  def update_fine_ajax
    if request.post?
      @batch   = Batch.find(params[:fine][:batch_id])
      @dates = FinanceFeeCollection.find(:all)
      @date = @fee_collection = FinanceFeeCollection.find(params[:fine][:date])
      @student = Student.find(params[:fine][:student]) if params[:fine][:student]
      @student ||= FinanceFee.first(:conditions=>"fee_collection_id = #{@date.id}",:joins=>'INNER JOIN students ON finance_fees.student_id = students.id').student
      @prev_student = @student.previous_fee_student(@date.id)
      @next_student = @student.next_fee_student(@date.id)
      
      @financefee = @student.finance_fee_by_date @date
      unless @financefee.transaction_id.blank?
        @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@financefee.transaction_id}\")", :order=>"created_at ASC")
      end
      unless params[:fine][:fee].to_f < 0
        @fine = (params[:fine][:fee])
      else
        @financefee.errors.add_to_base("#{t('flash24')}")
      end
      @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted IS NOT NULL"])
      @fee_particulars = @date.fees_particulars(@student)
      @due_date = @fee_collection.due_date

      @batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(@fee_collection.id)
      @student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.id)
      @category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.student_category_id)
      @total_discount = 0
      @total_discount += @batch_discounts.map{|s| s.discount}.sum unless @batch_discounts.nil?
      @total_discount += @student_discounts.map{|s| s.discount}.sum unless @student_discounts.nil?
      @total_discount += @category_discounts.map{|s| s.discount}.sum unless @category_discounts.nil?
      if @total_discount > 100
        @total_discount = 100
      end


      render :update do |page|
        page.replace_html "student", :partial => "student_fees_submission", :with => @fine

      end
    end
  end

  def search_logic                 #student search (fees submission)
    query = params[:query]
    if query.length>= 3
      @students_result = Student.find(:all,
        :conditions => ["first_name LIKE ? OR middle_name LIKE ? OR last_name LIKE ?
                            OR admission_no = ? OR (concat(first_name, \" \", last_name) LIKE ? ) ",
          "#{query}%","#{query}%","#{query}%",
          "#{query}", "#{query}" ],
        :order => "batch_id asc,first_name asc") unless query == ''
    else
      @students_result = Student.find(:all,
        :conditions => ["admission_no = ? " , query],
        :order => "batch_id asc,first_name asc") unless query == ''
    end
    render :layout => false
  end

  def fees_student_dates
    @student = Student.find(params[:id])
    @dates = @student.batch.fee_collection_dates
    @dates.reject!{|x|!FinanceFee.exists?(:fee_collection_id=>x.id, :student_id=>@student.id)}
  end

  def fees_submission_student
    
    @student = Student.find(params[:id])
    @date = @fee_collection = FinanceFeeCollection.find(params[:date])
    @financefee = @student.finance_fee_by_date(@date)
    
    @due_date = @fee_collection.due_date
    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted IS NOT NULL"])
    @fee_particulars = @date.fees_particulars(@student)
    unless @financefee.transaction_id.blank?
      @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@financefee.transaction_id}\")")
    end

    @batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(@fee_collection.id)
    @student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.id)
    @category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.student_category_id)
    @total_discount = 0
    @total_discount += @batch_discounts.map{|s| s.discount}.sum unless @batch_discounts.nil?
    @total_discount += @student_discounts.map{|s| s.discount}.sum unless @student_discounts.nil?
    @total_discount += @category_discounts.map{|s| s.discount}.sum unless @category_discounts.nil?
    if @total_discount > 100
      @total_discount = 100
    end
    
    render :update do |page|
      page.replace_html "fee_submission", :partial => "fees_submission_form"
    end

  end

  def update_student_fine_ajax

    @student = Student.find(params[:fine][:student])
    @date = @fee_collection = FinanceFeeCollection.find(params[:fine][:date])
    @financefee = @student.finance_fee_by_date(@date)
    unless params[:fine][:fee].to_f < 0
      @fine = (params[:fine][:fee])
      flash[:notice] = nil
    else
      flash[:notice] = "#{t('flash24')}"
    end

    @due_date = @fee_collection.due_date
    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted IS NOT NULL"])
    @fee_particulars = @date.fees_particulars(@student)

    @batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(@fee_collection.id)
    @student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.id)
    @category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.student_category_id)
    @total_discount = 0
    @total_discount += @batch_discounts.map{|s| s.discount}.sum unless @batch_discounts.nil?
    @total_discount += @student_discounts.map{|s| s.discount}.sum unless @student_discounts.nil?
    @total_discount += @category_discounts.map{|s| s.discount}.sum unless @category_discounts.nil?
    if @total_discount > 100
      @total_discount = 100
    end

    render :update do |page|
      page.replace_html "fee_submission", :partial => "fees_submission_form"
    end

  end

  def fees_submission_save

    @student = Student.find(params[:student])
    @date = @fee_collection = FinanceFeeCollection.find(params[:date])
    @financefee = @date.fee_transactions(@student.id)

    @due_date = @fee_collection.due_date
    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted IS NOT NULL"])
    @fee_particulars = @date.fees_particulars(@student)
    @batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(@fee_collection.id)
    @student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.id)
    @category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.student_category_id)
    @total_discount = 0
    @total_discount += @batch_discounts.map{|s| s.discount}.sum unless @batch_discounts.nil?
    @total_discount += @student_discounts.map{|s| s.discount}.sum unless @student_discounts.nil?
    @total_discount += @category_discounts.map{|s| s.discount}.sum unless @category_discounts.nil?
    if @total_discount > 100
      @total_discount = 100
    end
    total_fees = 0
    @fee_particulars.each do |p|
      total_fees += p.amount
    end
    unless params[:fine].nil?
      total_fees += params[:fine].to_f
    end
    unless @financefee.transaction_id.blank?
      @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@financefee.transaction_id}\")")
    end
    if request.post?
      unless params[:fees][:fees_paid].to_f < 0
        unless params[:fees][:fees_paid].to_f> params[:total_fees].to_f
          transaction = FinanceTransaction.new
          transaction.title = "#{t('receipt_no')}. F#{@financefee.id}"
          transaction.category = FinanceTransactionCategory.find_by_name("Fee")
          transaction.payee = @student
          transaction.finance = @financefee
          transaction.fine_included = true  unless params[:fine].nil?
          transaction.amount = params[:fees][:fees_paid].to_f
          transaction.fine_amount = params[:fine].to_f
          transaction.transaction_date = Date.today
          transaction.save
          unless @financefee.transaction_id.nil?
            tid =   @financefee.transaction_id.to_s + ",#{transaction.id}"
          else
            tid=transaction.id
          end
          is_paid = (params[:fees][:fees_paid].to_f == params[:total_fees].to_f) ? true : false
          @financefee.update_attributes(:transaction_id=>tid, :is_paid=>is_paid)
          unless @financefee.transaction_id.blank?
            @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@financefee.transaction_id}\")")
          end
          flash[:warning] = "#{t('flash14')}"
        else
          flash[:notice] = "#{t('flash19')}"
        end
      else
        flash[:notice] = "#{t('flash23')}"
      end
    end
    render :update do |page|
      page.replace_html "fee_submission", :partial => "fees_submission_form"
    end
  end


  #fees structure ----------------------
  
  def fees_student_structure_search_logic # student search fees structure
    query = params[:query]
    unless query.length < 3
      @students_result = Student.find(:all,
        :conditions => ["first_name LIKE ? OR middle_name LIKE ? OR last_name LIKE ?
                         OR admission_no = ? OR (concat(first_name, \" \", last_name) LIKE ? ) ",
          "#{query}%","#{query}%","#{query}%","#{query}", "#{query}" ],
        :order => "batch_id asc,first_name asc") unless query == ''
    else
      @students_result = Student.find(:all,
        :conditions => ["admission_no = ? " , query],
        :order => "batch_id asc,first_name asc") unless query == ''
    end
    render :layout => false
  end

  def fees_structure_dates
    @student = Student.find(params[:id])
    #@dates = @student.batch.fee_collection_dates
    @student_fees = FinanceFee.find_all_by_student_id(@student.id,:select=>'fee_collection_id')
    @student_dates = ""
    @student_fees.map{|s| @student_dates += s.fee_collection_id.to_s + ","}
    @dates = FinanceFeeCollection.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@student_dates}\") and is_deleted = 0")
  end

  def fees_structure_for_student
    @student = Student.find(params[:id])
    @fee_collection = FinanceFeeCollection.find params[:date]
    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted IS NOT NULL"])
    @fee_particulars = @fee_collection.fees_particulars(@student)

    @batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(@fee_collection.id)
    @student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.id)
    @category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.student_category_id)
    @total_discount = 0
    @total_discount += @batch_discounts.map{|s| s.discount}.sum unless @batch_discounts.nil?
    @total_discount += @student_discounts.map{|s| s.discount}.sum unless @student_discounts.nil?
    @total_discount += @category_discounts.map{|s| s.discount}.sum unless @category_discounts.nil?
    if @total_discount > 100
      @total_discount = 100
    end
    render :update do |page|
      page.replace_html "fees_structure" , :partial => "fees_structure"
    end
  end

  def student_fees_structure
    @student = Student.find(params[:id])
    @fee_collection = FinanceFeeCollection.find params[:id2]
    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted IS NOT NULL"])
    @fee_particulars = @fee_collection.fees_particulars(@student)
  end
  

  #fees defaulters-----------------------

  def fees_defaulters
    @courses = Course.active
    @batchs = []
    @dates = []
  end

  def update_batches
    @course = Course.find(params[:course_id])
    @batchs = @course.batches

    render :update do |page|
      page.replace_html "batches_list", :partial => "batches_list"
    end
  end

  def update_fees_collection_dates_defaulters
    @batch  = Batch.find(params[:batch_id])
    @dates = @batch.fee_collection_dates

    render :update do |page|
      page.replace_html "fees_collection_dates", :partial => "fees_collection_dates_defaulters"
    end
  end

  def fees_defaulters_students
    @batch   = Batch.find(params[:batch_id])
    @date = FinanceFeeCollection.find(params[:date])
    @students = @date.students
    @defaulters = @students.reject{|s| s.check_fee_pay(@date)}
    render :update do |page|
      page.replace_html "student", :partial => "student_defaulters"
    end
  end

  def fee_defaulters_pdf
    @batch   = Batch.find(params[:batch_id])
    @date = FinanceFeeCollection.find(params[:date])
    @students = @date.students.reject{|s| s.batch_id != @batch.id}
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
        
    render :pdf => 'fee_defaulters_pdf'
  end

  def pay_fees_defaulters
    @fine = params[:fine].to_f unless params[:fine].nil?
    @student = Student.find(params[:id])
    @date = @fee_collection = FinanceFeeCollection.find(params[:date])
    @financefee = @date.fee_transactions(@student.id)

    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted IS NOT NULL"])
    @fee_particulars = @date.fees_particulars(@student)

    @batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(@fee_collection.id)
    @student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.id)
    @category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.student_category_id)
    @total_discount = 0
    @total_discount += @batch_discounts.map{|s| s.discount}.sum unless @batch_discounts.nil?
    @total_discount += @student_discounts.map{|s| s.discount}.sum unless @student_discounts.nil?
    @total_discount += @category_discounts.map{|s| s.discount}.sum unless @category_discounts.nil?
    if @total_discount > 100
      @total_discount = 100
    end
    
    unless @financefee.transaction_id.blank?
      @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{@financefee.transaction_id}\")", :order=>"created_at ASC")
    end
    total_fees = 0
    @fee_particulars.each do |p|
      total_fees += p.amount
    end
    total_fees += @fine unless @fine.nil?

    if request.post?
      unless params[:fees][:fees_paid].to_f < 0
        unless params[:fees][:fees_paid].to_f> params[:total_fees].to_f
          transaction = FinanceTransaction.new
          transaction.title = "#{t('receipt_no')}. F#{@financefee.id}"
          transaction.category = FinanceTransactionCategory.find_by_name("Fee")
          transaction.payee = @student
          transaction.finance = @financefee
          transaction.amount = params[:fees][:fees_paid].to_f
          transaction.fine_included = true  unless @fine.nil?
          transaction.fine_amount = params[:fine].to_f
          transaction.transaction_date = Date.today
          transaction.save

          unless @financefee.transaction_id.nil?
            tid =   @financefee.transaction_id.to_s + ",#{transaction.id}"
          else
            tid=transaction.id
          end

          is_paid = (params[:fees][:fees_paid].to_f == params[:total_fees].to_f) ? true : false
          @financefee.update_attributes(:transaction_id=>tid, :is_paid=>is_paid)

          @paid_fees = FinanceTransaction.find(:all,:conditions=>"FIND_IN_SET(id,\"#{tid}\")")
          flash[:notice] = "#{t('flash14')}"
          redirect_to  :action => "pay_fees_defaulters",:id => @student,:date => @date
        else
          flash[:notice] = "#{t('flash19')}"
        end
      else
        flash[:notice] = "#{t('flash23')}"
      end
    
    end
  end

  def update_defaulters_fine_ajax
    @student = Student.find(params[:fine][:student])
    @date = FinanceFeeCollection.find(params[:fine][:date])
    @financefee = @date.fee_transactions(@student.id)
    @fee_collection = FinanceFeeCollection.find(params[:fine][:date])
    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted IS NOT NULL"])
    @fee_particulars = @date.fees_particulars(@student)
    unless params[:fine][:fee].to_f < 0
      @fine = params[:fine][:fee].to_f

      total_fees = 0
      @fee_particulars.each do |p|
        total_fees += p.amount
      end
      total_fees += @fine unless @fine.nil?
    else
      flash[:notice] = "#{t('flash24')}"
    end
    redirect_to  :action => "pay_fees_defaulters", :id=> @student.id, :date=> @date.id, :fine => @fine
  end

  def compare_report
    
  end

  def report_compare
    fixed_category_name
    @hr = Configuration.find_by_config_value("HR")
    @start_date = (params[:start_date]).to_date
    @end_date = (params[:end_date]).to_date
    @start_date2 = (params[:start_date2]).to_date
    @end_date2 = (params[:end_date2]).to_date
    @transactions = FinanceTransaction.find(:all,
      :order => 'transaction_date desc', :conditions => ["transaction_date >= '#{@start_date}' and transaction_date <= '#{@end_date}'"])
    @transactions2 = FinanceTransaction.find(:all,
      :order => 'transaction_date desc', :conditions => ["transaction_date >= '#{@start_date2}' and transaction_date <= '#{@end_date2}'"])
    @other_transaction_categories = FinanceTransaction.find(:all,params[:page], :conditions => ["transaction_date >= '#{@start_date}' and transaction_date <= '#{@end_date}'and category_id NOT IN (#{@fixed_cat_ids.join(",")})"],
      :order => 'transaction_date').map{|ft| ft.category}.uniq
    #    @other_transactions = FinanceTransaction.report(@start_date,@end_date,params[:page])
    @other_transaction_categories2 = FinanceTransaction.find(:all,params[:page], :conditions => ["transaction_date >= '#{@start_date2}' and transaction_date <= '#{@end_date2}'and category_id NOT IN (#{@fixed_cat_ids.join(",")})"],
      :order => 'transaction_date').map{|ft| ft.category}.uniq
    #    @transactions_fees = FinanceTransaction.total_fees(@start_date,@end_date)
    @transactions_fees2 = FinanceTransaction.total_fees(@start_date2,@end_date2)
    employees = Employee.find(:all)
    @salary = Employee.total_employees_salary(employees, @start_date, @end_date)
    @salary2 = Employee.total_employees_salary(employees, @start_date2, @end_date2)
    @donations_total = FinanceTransaction.donations_triggers(@start_date,@end_date)
    @donations_total2 = FinanceTransaction.donations_triggers(@start_date2,@end_date2)
    @transactions_fees = FinanceTransaction.total_fees(@start_date,@end_date)
    @transactions_fees2 = FinanceTransaction.total_fees(@start_date2,@end_date2)
    @batchs = Batch.find(:all)
    @grand_total = FinanceTransaction.grand_total(@start_date,@end_date)
    @grand_total2 = FinanceTransaction.grand_total(@start_date2,@end_date2)
    @category_transaction_totals = {}
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      @category_transaction_totals["#{category[:category_name]}"] =   FinanceTransaction.total_transaction_amount(category[:category_name],@start_date,@end_date)
    end
    @category_transaction_totals2 = {}
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      @category_transaction_totals2["#{category[:category_name]}"] =   FinanceTransaction.total_transaction_amount(category[:category_name],@start_date2,@end_date2)
    end
    @graph = open_flash_chart_object(960, 500, "graph_for_compare_monthly_report?start_date=#{@start_date}&end_date=#{@end_date}&start_date2=#{@start_date2}&end_date2=#{@end_date2}")
  end
 
  def month_date
    @start_date = params[:start]
    @end_date  = params[:end]
  end

  def partial_payment
    render :update do |page|
      page.replace_html "partial_payment", :partial => "partial_payment"
    end
  end


  #reports pdf---------------------------

  def pdf_fee_structure
    @student = Student.find(params[:id])
    @institution_name = Configuration.find_by_config_key("InstitutionName")
    @institution_address = Configuration.find_by_config_key("InstitutionAddress")
    @institution_phone_no = Configuration.find_by_config_key("InstitutionPhoneNo")
    @currency_type = Configuration.find_by_config_key("CurrencyType").config_value
    @fee_collection = FinanceFeeCollection.find params[:id2]
    @fee_category = FinanceFeeCategory.find(@fee_collection.fee_category_id,:conditions => ["is_deleted IS NOT NULL"])
    @fee_particulars = @fee_collection.fees_particulars(@student)
    @total = @student.total_fees(@fee_particulars)
    @batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(@fee_collection.id)
    @student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.id)
    @category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(@fee_collection.id,@student.student_category_id)
    @total_discount = 0
    @total_discount += @batch_discounts.map{|s| s.discount}.sum unless @batch_discounts.nil?
    @total_discount += @student_discounts.map{|s| s.discount}.sum unless @student_discounts.nil?
    @total_discount += @category_discounts.map{|s| s.discount}.sum unless @category_discounts.nil?
    if @total_discount > 100
      @total_discount = 100
    end
    render :pdf => 'pdf_fee_structure'
           
    #        respond_to do |format|
    #            format.pdf { render :layout => false }
    #        end
  end

  #graph------------------------------------
 

  def graph_for_update_monthly_report
    
    start_date = (params[:start_date]).to_date
    end_date = (params[:end_date]).to_date
    employees = Employee.find(:all)
    
    hr = Configuration.find_by_config_value("HR")
    donations_total = FinanceTransaction.donations_triggers(start_date,end_date)
    fees = FinanceTransaction.total_fees(start_date,end_date)
    income = FinanceTransaction.total_other_trans(start_date,end_date)[0]
    expense = FinanceTransaction.total_other_trans(start_date,end_date)[1]
    #    other_transactions = FinanceTransaction.find(:all,
    #      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id !='#{3}' and category_id !='#{2}'and category_id !='#{1}'"])
   

    x_labels = []
    data = []
    largest_value =0
    
    unless hr.nil?
      salary = Employee.total_employees_salary(employees,start_date,end_date)
      unless salary <= 0
        x_labels << "#{t('salary')}"
        data << salary-(salary*2)
        largest_value = salary if largest_value < salary
      end
    end
    unless donations_total <= 0
      x_labels << "#{t('donations')}"
      data << donations_total
      largest_value = donations_total if largest_value < donations_total
    end
     
    unless fees <= 0
      x_labels << "#{t('fees_text')}"
      data << fees
      largest_value = fees if largest_value < fees
    end

    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      transaction = FinanceTransaction.total_transaction_amount(category[:category_name],start_date,end_date)
      amount = transaction[:amount]
      unless amount <= 0
        x_labels << "#{category[:category_name]}"
        transaction[:category_type] == "income" ? data << amount : data << amount-(amount*2)
        largest_value = amount if largest_value < amount
      end
    end

    unless income <= 0
      x_labels << "#{t('other_income')}"
      data << income
      largest_value = income if largest_value < income
    end
    unless expense <= 0
      x_labels << "#{t('other_expense')}"
      data << expense-(expense*2)
      largest_value = expense if largest_value < expense
    end

    
    #    other_transactions.each do |trans|
    #      x_labels << trans.title
    #      if trans.category.is_income? and trans.master_transaction_id == 0
    #        data << trans.amount
    #      else
    #        data << ("-"+trans.amount.to_s).to_i
    #      end
    #      largest_value = trans.amount if largest_value < trans.amount
    #    end

    largest_value += 500

    bargraph = BarFilled.new()
    bargraph.width = 1;
    bargraph.colour = '#bb0000';
    bargraph.dot_size = 3;
    bargraph.text = "#{t('amount')}"
    bargraph.values = data

    x_axis = XAxis.new
    x_axis.labels = x_labels

    y_axis = YAxis.new
    y_axis.set_range(largest_value-(largest_value*2),largest_value,largest_value/5)

    title = Title.new("#{t('finance_transactions')}")

    x_legend = XLegend.new("Examination name")
    x_legend.set_style('{font-size: 14px; color: #778877}')

    y_legend = YLegend.new("Marks")
    y_legend.set_style('{font-size: 14px; color: #770077}')

    chart = OpenFlashChart.new
    chart.set_title(title)
    chart.set_x_legend = x_legend
    chart.set_y_legend = y_legend
    chart.y_axis = y_axis
    chart.x_axis = x_axis

    chart.add_element(bargraph)


    render :text => chart.render
 
  end
  def graph_for_compare_monthly_report

    start_date = (params[:start_date]).to_date
    end_date = (params[:end_date]).to_date
    start_date2 = (params[:start_date2]).to_date
    end_date2 = (params[:end_date2]).to_date
    employees = Employee.find(:all)

    hr = Configuration.find_by_config_value("HR")
    donations_total = FinanceTransaction.donations_triggers(start_date,end_date)
    donations_total2 = FinanceTransaction.donations_triggers(start_date2,end_date2)
    fees = FinanceTransaction.total_fees(start_date,end_date)
    fees2 = FinanceTransaction.total_fees(start_date2,end_date2)
    income = FinanceTransaction.total_other_trans(start_date,end_date)[0]
    income2 = FinanceTransaction.total_other_trans(start_date2,end_date2)[0]
    expense = FinanceTransaction.total_other_trans(start_date,end_date)[1]
    expense2 = FinanceTransaction.total_other_trans(start_date2,end_date2)[1]

    #    other_transactions = FinanceTransaction.find(:all,
    #      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id !='#{3}' and category_id !='#{2}'and category_id !='#{1}'"])
    #    other_transactions2 = FinanceTransaction.find(:all,
    #      :conditions => ["transaction_date >= '#{start_date2}' and transaction_date <= '#{end_date2}'and category_id !='#{3}' and category_id !='#{2}'and category_id !='#{1}'"])


    x_labels = []
    data = []
    data2 = []
    largest_value =0

    unless hr.nil?
      salary = Employee.total_employees_salary(employees,start_date,end_date)
      salary2 = Employee.total_employees_salary(employees,start_date2,end_date2)
      unless salary <= 0 and salary2 <= 0
        x_labels << "#{t('salary')}"
        data << salary-(salary*2)
        data2 << salary2-(salary2*2)
        largest_value = salary if largest_value < salary
        largest_value = salary2 if largest_value < salary2
      end
    end
    unless donations_total <= 0 and donations_total2 <= 0
      x_labels << "#{t('donations')}"
      data << donations_total
      data2 << donations_total2
      largest_value = donations_total if largest_value < donations_total
      largest_value = donations_total2 if largest_value < donations_total2
    end

    unless fees <= 0 and fees2 <= 0
      x_labels << "#{t('fees_text')}"
      data << fees
      data2 << fees2
      largest_value = fees if largest_value < fees
      largest_value = fees2 if largest_value < fees2
    end
       
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      transaction1 =   FinanceTransaction.total_transaction_amount(category[:category_name],start_date,end_date)
      transaction2 =   FinanceTransaction.total_transaction_amount(category[:category_name],start_date2,end_date2)
      amount1 = transaction1[:amount]
      amount2 = transaction2[:amount]
      unless amount1 <= 0 and amount2 <= 0
        x_labels << "#{category[:category_name]}"
        transaction1[:category_type] == "income" ? data << amount1 : data << amount1-(amount1*2)
        transaction2[:category_type] == "income" ? data2 << amount2 : data2 << amount2-(amount2*2)
        largest_value = amount1 if largest_value < amount1
        largest_value = amount2 if largest_value < amount2
      end
    end

    unless income <= 0 and income2 <= 0
      x_labels << "#{t('other_income')}"
      data << income
      data2 << income2
      largest_value = income if largest_value < income
      largest_value = income2 if largest_value < income2
    end

    unless expense <= 0 and expense2 <= 0
      x_labels << "#{t('other_expense')}"
      data << expense-(expense*2)
      data2 << expense2-(expense2*2)
      largest_value = expense if largest_value < expense
      largest_value = expense2 if largest_value < expense2
    end

    #       other = 0
    #    other_transactions.each do |trans|
    #
    #      if trans.category.is_income? and trans.master_transaction_id == 0
    #        other += trans.amount
    #      else
    #        other -= trans.amount
    #      end
    #    end
    #    x_labels << "other"
    #    data << other
    #    largest_value = other if largest_value < other
    #    other2 = 0
    #    other_transactions2.each do |trans2|
    #      if trans2.category.is_income?
    #        other2 += trans2.amount
    #      else
    #        other2 -= trans2.amount
    #      end
    #    end
    #    data2 << other2
    #    largest_value = other2 if largest_value < other2

    largest_value += 500

    bargraph = BarFilled.new()
    bargraph.width = 1;
    bargraph.colour = '#bb0000';
    bargraph.dot_size = 3;
    bargraph.text = "#{t('for_the_period')} #{start_date}-#{end_date}"
    bargraph.values = data
    bargraph2 = BarFilled.new()
    bargraph2.width = 1;
    bargraph2.colour = '#000000';
    bargraph2.dot_size = 3;
    bargraph2.text = "#{t('for_the_period')} #{start_date2}-#{end_date2}"
    bargraph2.values = data2

    x_axis = XAxis.new
    x_axis.labels = x_labels

    y_axis = YAxis.new
    y_axis.set_range(largest_value-(largest_value*2),largest_value,largest_value/5)

    title = Title.new("#{t('finance_transactions')}")

    x_legend = XLegend.new("#{t('examination_name')}")
    x_legend.set_style('{font-size: 14px; color: #778877}')

    y_legend = YLegend.new("#{t('marks')}")
    y_legend.set_style('{font-size: 14px; color: #770077}')

    chart = OpenFlashChart.new
    chart.set_title(title)
    chart.set_x_legend = x_legend
    chart.set_y_legend = y_legend
    chart.y_axis = y_axis
    chart.x_axis = x_axis

    chart.add_element(bargraph)
    chart.add_element(bargraph2)


    render :text => chart.render

  end
  
  #ddnt complete this graph!

  def graph_for_transaction_comparison

    start_date = (params[:start_date]).to_date
    end_date = (params[:end_date]).to_date
    employees = Employee.find(:all)

    hr = Configuration.find_by_config_value("HR")
    donations_total = FinanceTransaction.donations_triggers(start_date,end_date)
    fees = FinanceTransaction.total_fees(start_date,end_date)
    income = FinanceTransaction.total_other_trans(start_date,end_date)[0]
    expense = FinanceTransaction.total_other_trans(start_date,end_date)[1]
    #    other_transactions = FinanceTransaction.find(:all,
    #      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id !='#{3}' and category_id !='#{2}'and category_id !='#{1}'"])


    x_labels = []
    data1 = []
    data2 = []
    
    largest_value =0

    unless hr.nil?
      salary = Employee.total_employees_salary(employees,start_date,end_date)
    end
    unless salary <= 0
      x_labels << "#{t('salary')}"
      data << salary-(salary*2)
      largest_value = salary if largest_value < salary
    end
    unless donations_total <= 0
      x_labels << "#{t('donations')}"
      data << donations_total
      largest_value = donations_total if largest_value < donations_total
    end

    unless fees <= 0
      x_labels << "#{t('fees_text')}"
      data << fees
      largest_value = fees if largest_value < fees
    end

    unless income <= 0
      x_labels << "#{t('other_income')}"
      data << income
      largest_value = income if largest_value < income
    end
        
    unless expense <= 0
      x_labels << "#{t('other_expense')}"
      data << expense
      largest_value = expense if largest_value < expense
    end
    
    #    other_transactions.each do |trans|
    #      x_labels << trans.title
    #      if trans.category.is_income? and trans.master_transaction_id == 0
    #        data << trans.amount
    #      else
    #        data << ("-"+trans.amount.to_s).to_i
    #      end
    #      largest_value = trans.amount if largest_value < trans.amount
    #    end

    largest_value += 500

    bargraph = BarFilled.new()
    bargraph.width = 1;
    bargraph.colour = '#bb0000';
    bargraph.dot_size = 3;
    bargraph.text = "#{t('amount')}"
    bargraph.values = data

    x_axis = XAxis.new
    x_axis.labels = x_labels

    y_axis = YAxis.new
    y_axis.set_range(largest_value-(largest_value*2),largest_value,largest_value/5)

    title = Title.new("#{t('finance_transactions')}")

    x_legend = XLegend.new("#{t('examination_name')}")
    x_legend.set_style('{font-size: 14px; color: #778877}')

    y_legend = YLegend.new("#{t('marks')}")
    y_legend.set_style('{font-size: 14px; color: #770077}')

    chart = OpenFlashChart.new
    chart.set_title(title)
    chart.set_x_legend = x_legend
    chart.set_y_legend = y_legend
    chart.y_axis = y_axis
    chart.x_axis = x_axis

    chart.add_element(bargraph)


    render :text => chart.render
 
   
  end
  #fee Discount
  def fee_discounts
    @batches = Batch.active
  end

  def fee_discount_new
    @batches = Batch.active
  end

  def load_discount_create_form
    if params[:type]== "batch_wise"
      @fee_categories = FinanceFeeCategory.common_active
      @fee_discount = BatchFeeDiscount.new
      render :update do |page|
        page.replace_html "form-box", :partial => "batch_wise_discount_form"
        page.replace_html 'form-errors', :text =>""
      end
    elsif params[:type]== "category_wise"
      @fee_categories = FinanceFeeCategory.common_active
      @student_categories = StudentCategory.active
      render :update do |page|
        page.replace_html "form-box", :partial => "category_wise_discount_form"
        page.replace_html 'form-errors', :text =>""
      end
    elsif params[:type] == "student_wise"
      @courses = Course.active
      render :update do |page|
        page.replace_html "form-box", :partial => "student_wise_discount_form"
        page.replace_html 'form-errors', :text =>""
      end
    end
  end

  def load_discount_batch
    @course = Course.find(params[:id])
    @batches = @course.batches.active
    render :update do |page|
      page.replace_html "batch-box", :partial => "fee_discount_batch_list"
    end
  end

  def load_batch_fee_category
    @fees_categories = FinanceFeeCategory.find_all_by_batch_id((params[:batch]),:conditions=>"is_deleted = 0 and is_master = 1")
    render :update do |page|
      page.replace_html "fee-category-box", :partial => "fee_discount_category_list"
    end
  end

  def batch_wise_discount_create
    unless params[:fee_collection].blank?
      params[:fee_collection][:category_ids].each do |c|
        @fee_category = FinanceFeeCategory.find(c)
        @fee_discount = BatchFeeDiscount.new(params[:fee_discount])
        @fee_discount.finance_fee_category_id = c
        @fee_discount.receiver_id =  @fee_category.batch_id
        unless @fee_discount.save
          @error = true
        end
      end
    else
      @fee_discount = BatchFeeDiscount.new(params[:fee_discount])
      @fee_discount.errors.add_to_base("#{t('fees_category_cant_be_blank')}")
      @error = true
    end

  end

  def category_wise_fee_discount_create
    unless params[:fee_collection].blank?
      params[:fee_collection][:category_ids].each do |c|
        @fee_category = FinanceFeeCategory.find(c)
        @fee_discount = StudentCategoryFeeDiscount.new(params[:fee_discount])
        @fee_discount.finance_fee_category_id = c
        unless @fee_discount.save
          @error = true
        end
      end
    else
      @fee_discount = StudentCategoryFeeDiscount.new(params[:fee_discount])
      @fee_discount.errors.add_to_base("#{t('batch_cant_be_blank')}")
      @error = true
    end
  end

  def student_wise_fee_discount_create
    @error = false
    @fee_discount = StudentFeeDiscount.new(params[:fee_discount])
    unless (params[:fee_discount][:finance_fee_category_id]).blank?
      @fee_category = FinanceFeeCategory.find(@fee_discount.finance_fee_category_id)
      unless (params[:students]).blank?
        admission_no = (params[:students]).split(",")
        admission_no.each do |a|
          s = Student.find_by_admission_no(a)
          unless s.nil?
            if FeeDiscount.find_by_type_and_receiver_id('StudentFeeDiscount',s.id,:conditions=>"finance_fee_category_id = #{@fee_category.id}").present?
              @error = true
              @fee_discount.errors.add_to_base("#{t('flash20')} - #{a}")
            end
            unless (s.batch_id == @fee_category.batch_id)
              @error = true
              @fee_discount.errors.add_to_base("#{a} #{t('does_not_belong_to_batch')} #{@fee_category.batch.full_name}")
            end
          else
            @error = true
            @fee_discount.errors.add_to_base("#{a} #{t('is_invalid_admission_no')}")
          end
        end
        unless @error
          admission_no.each do |a|
            s = Student.find_by_admission_no(a)
            @fee_discount = StudentFeeDiscount.new(params[:fee_discount])
            @fee_discount.receiver_id = s.id
            unless @fee_discount.save
              @error = true
            end
          end
        end
      else
        @error = true
        @fee_discount.errors.add_to_base("#{t('admission_cant_be_blank')}")
      end
    else
      @error = true
      @fee_discount.errors.add_to_base("#{t('fees_category_cant_blank')}")
    end
  end
  

  def update_master_fee_category_list
    @batch = Batch.find(params[:id])
    @fee_categories = FinanceFeeCategory.find_all_by_batch_id(@batch.id, :conditions=>"is_master=1 and is_deleted= 0")
    render :update do |page|
      page.replace_html "master-category-box", :partial => "update_master_fee_category_list"
    end
  end

  def show_fee_discounts
    @fee_category = FinanceFeeCategory.find(params[:id])
    @discounts = @fee_category.fee_discounts
    @fee_category.is_collection_open ? @discount_edit = false : @discount_edit = true
    render :update do |page|
      page.replace_html "discount-box", :partial => "show_fee_discounts"
    end
  end

  def edit_fee_discount
    @fee_discount = FeeDiscount.find(params[:id])
  end

  def update_fee_discount
    @fee_discount = FeeDiscount.find(params[:id])
    unless @fee_discount.update_attributes(params[:fee_discount])
      @error = true
    else
      @fee_category = @fee_discount.finance_fee_category
      @discounts = @fee_category.fee_discounts
      @fee_category.is_collection_open ? @discount_edit = false : @discount_edit = true
    end
  end

  def delete_fee_discount
    @fee_discount = FeeDiscount.find(params[:id])
    @fee_category = FinanceFeeCategory.find(@fee_discount.finance_fee_category_id)
    @error = true  unless @fee_discount.destroy
    unless @fee_category.nil?
      @discounts = @fee_category.fee_discounts
      @fee_category.is_collection_open ? @discount_edit = false : @discount_edit = true
    end
    render :update do |page|
      page.replace_html "discount-box", :partial => "show_fee_discounts"
      page.replace_html "flash-notice", :text => "<p class='flash-msg'>#{t('discount_deleted_successfully')}.</p>"
    end

  end

  def collection_details_view
    @fee_collection = FinanceFeeCollection.find(params[:id])
    @particulars = @fee_collection.fee_collection_particulars
    @discounts = @fee_collection.fee_collection_discounts
  end

  def fixed_category_name
    @cat_names = ['Fee','Salary','Donation']
    @plugin_cat = []
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      @cat_names << "#{category[:category_name]}"
      @plugin_cat << "#{category[:category_name]}"
    end
    @fixed_cat_ids = FinanceTransactionCategory.find(:all,:conditions=>{:name=>@cat_names}).collect(&:id)
  end
end
