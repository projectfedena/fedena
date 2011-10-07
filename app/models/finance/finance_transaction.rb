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
  validates_presence_of :category,:message=>'not specified.'
  validates_numericality_of :amount, :greater_than_or_equal_to => 0, :message => 'must be positive'

  after_create  :create_auto_transaction
  after_update  :update_auto_transaction
  after_destroy :delete_auto_transaction

  def self.report(start_date,end_date,page)
    cat_names = ['Fee','Salary','Donation','Library','Hostel','Transport']
    fixed_cat_ids = FinanceTransactionCategory.find(:all,:conditions=>{:name=>cat_names}).collect(&:id)
    self.find(:all,
      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id NOT IN (#{fixed_cat_ids.join(",")})"],
      :order => 'transaction_date' )
  end

  def self.grand_total(start_date,end_date)
    fee_id = FinanceTransactionCategory.find_by_name("Fee").id
    donation_id = FinanceTransactionCategory.find_by_name("Donation").id
    cat_names = ['Fee','Salary','Donation','Library','Hostel','Transport']
    fixed_cat_ids = FinanceTransactionCategory.find(:all,:conditions=>{:name=>cat_names}).collect(&:id)
    other_transactions = FinanceTransaction.find(:all ,
      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id NOT IN (#{fixed_cat_ids.join(",")})"])
    transactions_fees = FinanceTransaction.find(:all,
      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id ='#{fee_id}'"])
    employees = Employee.find(:all)
    donations = FinanceTransaction.find(:all,
      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id ='#{donation_id}'"])
    trigger = FinanceTransactionTrigger.find(:all)
    hr = Configuration.find_by_config_value("HR")
    income_total = 0
    expenses_total = 0
    fees_total =0
    salary = 0

    unless hr.nil?
      salary = Employee.total_employees_salary(employees, start_date, end_date)
      expenses_total += salary
    end
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
    
    other_transactions.each do |t|
      if t.category.is_income?
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
    transactions_fees = FinanceTransaction.find(:all,
      :conditions => ["transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}'and category_id ='#{fee_id}'"])
    transactions_fees.each do |f|
      fees += f.amount
    end
    fees
  end

  def self.total_other_trans(start_date,end_date)
    cat_names = ['Fee','Salary','Donation','Library','Hostel','Transport']
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
        :conditions => ["finance_transaction_categories.is_income = 1 and finance_transaction_categories.id != 2 and finance_transaction_categories.id != 3 and transaction_date >= '#{start_date}' and transaction_date <= '#{end_date}' "])
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
    stu ||= ArchivedStudent.find_by_former_id(self.payee.id)
  end


  def delete_auto_transaction
    FinanceTransaction.find_all_by_master_transaction_id(self.id).each do |f|
        f.destroy
    end
  end

end
