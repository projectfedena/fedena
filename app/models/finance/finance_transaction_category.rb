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
class FinanceTransactionCategory < ActiveRecord::Base
  has_many :finance_transactions, :class_name => 'FinanceTransaction', :foreign_key => 'category_id'
  has_one  :trigger, :class_name => "FinanceTransactionTrigger", :foreign_key => "finance_category_id"

  validates_presence_of :name
  validates_uniqueness_of  :name, :case_sensitive => false

  named_scope :expense_categories, :conditions => "is_income = false AND name NOT LIKE 'Salary'and deleted = 0"

  def self.income_category_names
    cat_names = ['Fee', 'Salary', 'Donation']
    FedenaPlugin::FINANCE_CATEGORY.each do |category|
      cat_names << "#{category[:category_name]}"
    end
    cat_names
  end

  INCOME_CATEGORY_NAMES = self.income_category_names
  FIX_CATEGORY_NAMES = INCOME_CATEGORY_NAMES.map(&:downcase)

  def self.income_categories
    self.all(:conditions => ["is_income = true AND name NOT IN (?) and deleted = 0", INCOME_CATEGORY_NAMES])
  end

  def fixed?
    FIX_CATEGORY_NAMES.include?(self.name.downcase)
  end

  def total_income(start_date, end_date)
    is_income ? self.finance_transactions.sum(:amount, :conditions => ["transaction_date BETWEEN ? AND ? and master_transaction_id = 0", start_date, end_date]) : 0
  end

  def total_expense(start_date,end_date)
    if is_income
      self.finance_transactions.sum(:amount, :conditions => ["transaction_date BETWEEN ? AND ? and master_transaction_id != 0", start_date, end_date])
    else
      self.finance_transactions.sum(:amount, :conditions => ["transaction_date BETWEEN ? AND ?", start_date, end_date])
    end
  end

end
