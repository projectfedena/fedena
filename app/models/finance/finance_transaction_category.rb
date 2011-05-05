class FinanceTransactionCategory < ActiveRecord::Base
  has_many :finance_transactions
  has_one  :trigger, :class_name => "FinanceTransactionTrigger", :foreign_key => "category_id"


  validates_presence_of :name

  named_scope :expense_categories, :conditions => "is_income = false AND name NOT LIKE 'Salary'"
  named_scope :income_categories, :conditions => "is_income = true AND name NOT LIKE 'Fee' AND name NOT LIKE 'Donation'"

#  def self.expense_categories
#    FinanceTransactionCategory.all(:conditions => "is_income = false AND name NOT LIKE 'Salary'")
#  end
#
#  def self.income_categories
#    FinanceTransactionCategory.all(:conditions => "is_income = true AND name NOT LIKE 'Fee' AND name NOT LIKE 'Donation'")
#  end

end
