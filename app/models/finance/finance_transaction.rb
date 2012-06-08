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

class FinanceTransaction < ActiveRecord::Base
  belongs_to :category, :class_name => 'FinanceTransactionCategory', :foreign_key => 'category_id'
  belongs_to :student
  belongs_to :finance, :polymorphic => true
  belongs_to :payee, :polymorphic => true
  cattr_reader :per_page
  validates_presence_of :title,:amount,:transaction_date
  validates_presence_of :category,:message=>"#{t('not_specified')}."
  validates_numericality_of :amount, :greater_than_or_equal_to => 0, :message => "#{t('must_be_positive')}"

  after_create  :create_auto_transaction
  after_update  :update_auto_transaction
  after_destroy :delete_auto_transaction
  after_create :add_voucher_or_receipt_number

  def self.report(start_date,end_date,page)
    cat_names = ['Fee','Salary','Donation']
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      cat_names << "#{category[:category_name]}"
    end
    fixed_cat_ids = FinanceTransactionCategory.find(:all,:conditions=>{:name=>cat_names}).collect(&:id)
    self.find(:all,
      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id NOT IN (#{fixed_cat_ids.join(",")})"],
      :order => 'transaction_date' )
  end

  def self.grand_total(start_date,end_date)
    fee_id = FinanceTransactionCategory.find_by_name("Fee").id
    donation_id = FinanceTransactionCategory.find_by_name("Donation").id
    cat_names = ['Fee','Salary','Donation']
    plugin_name = []
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      cat_names << "#{category[:category_name]}"
      plugin_name << "#{category[:category_name]}"
    end
    fixed_categories = FinanceTransactionCategory.find(:all,:conditions=>{:name=>cat_names})
    fixed_cat_ids = fixed_categories.collect(&:id)
    fixed_transactions = FinanceTransaction.find(:all ,
      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id IN (#{fixed_cat_ids.join(",")})"])
    other_transactions = FinanceTransaction.find(:all ,
      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id NOT IN (#{fixed_cat_ids.join(",")})"])
    #    transactions_fees = FinanceTransaction.find(:all,
    #      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id ='#{fee_id}'"])
    #    donations = FinanceTransaction.find(:all,
    #      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id ='#{donation_id}'"])
    trigger = FinanceTransactionTrigger.find(:all)
    hr = Configuration.find_by_config_value("HR")
    income_total = 0
    expenses_total = 0
    fees_total =0
    salary = 0
     
    unless hr.nil?
      salary = MonthlyPayslip.total_employees_salary(start_date, end_date)
      expenses_total += salary[:total_salary].to_f
    end

    transactions_fees = fixed_transactions.reject{|tr|tr.category_id != fee_id}
    donations = fixed_transactions.reject{|tr|tr.category_id != donation_id}

    donations.each do |d|
      if d.master_transaction_id == 0
        income_total +=d.amount
      else
        expenses_total +=d.amount
      end
      
    end
    transactions_fees.each do |fees|
      income_total +=fees.amount
      fees_total += fees.amount
    end

    # plugin transactions
    plugin_name.each do |p|
      category = fixed_categories.reject{|cat|cat.name.downcase != p.downcase}
      unless category.blank?
        cat_id = category.first.id
        transactions_plugin = fixed_transactions.reject{|tr|tr.category_id != cat_id}
        transactions_plugin.each do |t|
          if t.category.is_income?
            income_total +=t.amount
          else
            expenses_total +=t.amount
          end
        end
      end
    end
    
    other_transactions.each do |t|
      if t.category.is_income? and t.master_transaction_id == 0
        income_total +=t.amount
      else
        expenses_total +=t.amount
      end
    end
    income_total-expenses_total
    
  end

  def self.total_fees(start_date,end_date)
    fee_id = FinanceTransactionCategory.find_by_name("Fee").id
    fees = 0
    fees = FinanceTransaction.find(:all,
      :conditions => ["transaction_date >= '#{start_date.to_date}' and transaction_date <= '#{end_date.to_date}'and category_id ='#{fee_id}'"]).map{|ft| ft.amount}.sum
  end

  def self.total_other_trans(start_date,end_date)
    cat_names = ['Fee','Salary','Donation']
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      cat_names << "#{category[:category_name]}"
    end
    fixed_cat_ids = FinanceTransactionCategory.find(:all,:conditions=>{:name=>cat_names}).collect(&:id)
    fees = 0
    transactions = FinanceTransaction.find(:all, :conditions => ["created_at >= '#{start_date}' and created_at <= '#{end_date}'and category_id NOT IN (#{fixed_cat_ids.join(",")})"])
    transactions_income = transactions.reject{|x| !x.category.is_income? }.compact
    transactions_expense = transactions.reject{|x| x.category.is_income? }.compact
    income = 0
    expense = 0
    transactions_income.each do |f|
      income += f.amount
    end
    transactions_expense.each do |f|
      expense += f.amount
    end
    [income,expense]
  end

  def self.donations_triggers(start_date,end_date)
    donation_id = FinanceTransactionCategory.find_by_name("Donation").id
    donations_income =0
    donations_expenses =0
    donations = FinanceTransaction.find(:all,:conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}' and master_transaction_id = 0 and category_id ='#{donation_id}'"])
    trigger = FinanceTransaction.find(:all,:conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}' and master_transaction_id != 0 and category_id ='#{donation_id}'"])
    donations.each do |d|
      if d.category.is_income?
        donations_income+=d.amount
      else
        donations_expenses+=d.amount
      end
    end
    trigger.each do |t|
      #unless t.finance_category.id.nil?
      # if d.category_id == t.finance_category.id
      donations_expenses += t.amount
      #end
      #end
    end
    donations_income-donations_expenses
    
  end


  def self.expenses(start_date,end_date)
    expenses = FinanceTransaction.find(:all, :select=>'finance_transactions.*', :joins=>' INNER JOIN finance_transaction_categories ON finance_transaction_categories.id = finance_transactions.category_id',\
        :conditions => ["finance_transaction_categories.is_income = 0 and finance_transaction_categories.id != 1 and transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'"])
    expenses
  end

  def self.incomes(start_date,end_date)
    incomes = FinanceTransaction.find(:all, :select=>'finance_transactions.*', :joins=>' INNER JOIN finance_transaction_categories ON finance_transaction_categories.id = finance_transactions.category_id',\
        :conditions => ["finance_transaction_categories.is_income = 1 and transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}' "])
    incomes = incomes.reject{|income| (income.category.is_fixed or income.master_transaction_id != 0)}
    incomes
  end

  def create_auto_transaction
    if self.master_transaction_id == 0
      trigger = FinanceTransactionTrigger.find(:all,:conditions=>['finance_category_id = ?',self.category_id])
      trigger.each do |t|
        trigger_amount = (self.amount * t.percentage ) / 100
        FinanceTransaction.create(:title=> self.title + ' - ' + t.title.to_s ,:transaction_date=>self.transaction_date, \
            :amount=>trigger_amount,:category_id =>self.category_id,:master_transaction_id=>self.id)
      end
    end
  end

  def update_auto_transaction
    FinanceTransaction.find_all_by_master_transaction_id(self.id).each do |f|
      f.destroy
    end
    if self.master_transaction_id == 0
      trigger = FinanceTransactionTrigger.find(:all,:conditions=>['finance_category_id = ?',self.category_id])
      trigger.each do |t|
        trigger_amount = (self.amount * t.percentage ) / 100
        FinanceTransaction.create(:title=> self.title + ' - ' + t.title.to_s ,:transaction_date=>self.transaction_date, \
            :amount=>trigger_amount,:category_id =>self.category_id,:master_transaction_id=>self.id)
      end
    end
  end

  def student_payee
    stu = self.payee
    stu ||= ArchivedStudent.find_by_former_id(self.payee_id)
  end


  def delete_auto_transaction
    FinanceTransaction.find_all_by_master_transaction_id(self.id).each do |f|
      f.destroy
    end
  end

  def self.total_transaction_amount(transaction_category,start_date,end_date)
    amount = 0
    finance_transaction_category = FinanceTransactionCategory.find_by_name("#{transaction_category}")
    category_type = finance_transaction_category.is_income ? "income" : "expense"
    transactions = FinanceTransaction.find(:all,
      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id ='#{finance_transaction_category.id}'"])
    transactions.each {|transaction| amount += transaction.amount}
    return {:amount=>amount,:category_type=>category_type}
  end
  
  def add_voucher_or_receipt_number
    if self.category.is_income and self.master_transaction_id == 0
      last_transaction = FinanceTransaction.last(:conditions=>"receipt_no IS NOT NULL")
      last_receipt_no = last_transaction.receipt_no unless last_transaction.nil?
      unless last_receipt_no.nil?
        receipt_split = last_receipt_no.to_s.scan(/[A-Z]+|\d+/i)
        if receipt_split[1].blank?
          receipt_number = receipt_split[0].next
        else
          receipt_number = receipt_split[0]+receipt_split[1].next
        end
      else
        receipt_number = "1"
      end
      self.update_attributes(:receipt_no=>receipt_number)
    else
      last_transaction = FinanceTransaction.last(:conditions=>"voucher_no IS NOT NULL")
      last_voucher_no = last_transaction.voucher_no unless last_transaction.nil?
      unless last_voucher_no.nil?
        voucher_split = last_voucher_no.to_s.scan(/[A-Z]+|\d+/i)
        if voucher_split[1].blank?
          voucher_number = voucher_split[0].next
        else
          voucher_number = voucher_split[0]+voucher_split[1].next
        end
      else
        voucher_number = "1"
      end
      self.update_attributes(:voucher_no=>voucher_number)
    end
  end
end
