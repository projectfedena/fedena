class FinanceFeeCollection < ActiveRecord::Base
  belongs_to :batch
  has_many :finance_fees, :foreign_key =>"fee_collection_id"
  has_many :students, :through => :finance_fees
  belongs_to :fee_category,:class_name => "FinanceFeeCategory"

  validates_presence_of :name,:start_date,:fee_category_id,:end_date,:due_date

  def full_name
    "#{name} - #{start_date.to_s}"
  end

  def fee_transactions(student_id)
    FinanceFee.find_by_fee_collection_id_and_student_id(self.id,student_id)
  end

  def check_transaction(transactions)
    transactions.finance_fees_id.nil? ? false : true
   
  end

  def self.shorten_string(string, count)
    if string.length >= count
      shortened = string[0, count]
      splitted = shortened.split(/\s/)
      words = splitted.length
      splitted[0, words-1].join(" ") + ' ...'
    else
      string
    end
  end

  def check_fee_category
    finance_fees = FinanceFee.find_all_by_fee_collection_id(self.id)
    flag = 1
    finance_fees.each do |f|
      flag = 0 unless f.transaction_id.nil?
    end
    flag == 1 ? true : false
  end
end
