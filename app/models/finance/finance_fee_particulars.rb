class FinanceFeeParticulars < ActiveRecord::Base

  belongs_to :finance_fee_category
  belongs_to :student_category
  validates_presence_of :name,:amount
  validates_numericality_of :amount
  cattr_reader :per_page
  @@per_page = 10
  
  

end
