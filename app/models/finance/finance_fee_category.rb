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
class FinanceFeeCategory < ActiveRecord::Base
  belongs_to :batch
  belongs_to :student

  has_many   :fee_particulars, :class_name => "FinanceFeeParticular"
  has_many   :fee_collections, :class_name => "FinanceFeeCollection"
  has_many   :fee_discounts

  cattr_reader :per_page

  @@per_page = 10

  validates_presence_of :name
  validates_presence_of :batch_id,:message => "#{t('not_specified')}"
  validates_uniqueness_of :name, :scope => [:batch_id, :is_deleted], :if => 'is_deleted == false'

  def fees(student)
    FinanceFeeParticular.find_all_by_finance_fee_category_id(self.id,
      :conditions => ["((student_category_id IS NULL AND admission_no IS NULL) OR (student_category_id = ? AND admission_no IS NULL) OR (student_category_id IS NULL AND admission_no = ?)) AND is_deleted = ?", student.student_category_id, student.admission_no, false])
  end

  def check_fee_collection
    FinanceFeeCollection.find_all_by_fee_category_id(self.id, :conditions => { :is_deleted => 0 }).empty?
  end

  def check_fee_collection_for_additional_fees
    fee_collection = FinanceFeeCollection.find_all_by_fee_category_id(self.id)
    fee_collection.each { |fee| return true if fee.check_fee_category == true }
    return false
  end

  def delete_particulars
    self.fee_particulars.each { |fees| fees.update_attributes(:is_deleted => true) }
  end

  def student_fee_balance(student, date)
    particulars = FinanceFeeParticular.find_all_by_finance_fee_category_id(self.id,
      :conditions => ["( (student_category_id IS NULL AND admission_no IS NULL) OR (student_category_id = ? AND admission_no IS NULL) OR (student_category_id IS NULL AND admission_no = ?) ) AND is_deleted = ?", student.student_category_id, student.admission_no, false])
    financefee = student.finance_fee_by_date(date)

    paid_fees = FinanceTransaction.find(:all, :conditions => ["FIND_IN_SET(id, ?)", financefee.transaction_id]) unless financefee.transaction_id.blank?

    batch_discounts = BatchFeeDiscount.find_all_by_finance_fee_category_id(self.id)
    student_discounts = StudentFeeDiscount.find_all_by_finance_fee_category_id_and_receiver_id(self.id, student.id)
    category_discounts = StudentCategoryFeeDiscount.find_all_by_finance_fee_category_id(self.id, :joins => 'INNER JOIN students ON fee_discounts.receiver_id = students.student_category_id')
    total_discount = 0
    total_discount += batch_discounts.map{|s| s.discount}.sum unless batch_discounts.nil?
    total_discount += student_discounts.map{|s| s.discount}.sum unless student_discounts.nil?
    total_discount += category_discounts.map{|s| s.discount}.sum unless category_discounts.nil?

    total_discount = 100 if total_discount > 100

    total_fees = 0
    if particulars.present?
      total_fees += particulars.collect{|x|x.amount.to_f}.sum
      total_fees = (total_fees - ((total_fees*total_discount)/100))

      if paid_fees.present?
        paid = 0
        paid += paid_fees.collect{|x|x.amount.to_f}.sum
        total_fees -= paid
        trans = FinanceTransaction.find(financefee.transaction_id)
        total_fees += trans.fine_amount.to_f if trans && trans.fine_included
      end
    end
    return total_fees
  end

  def self.common_active
    self.find(:all , :conditions => ["finance_fee_categories.is_master = ? AND finance_fee_categories.is_deleted = ?", 1, false], :joins => "INNER JOIN batches on finance_fee_categories.batch_id = batches.id AND batches.is_active = 1 AND batches.is_deleted = 0 ", :group => :name)
  end


  def is_collection_open
    collection = FinanceFeeCollection.find_all_by_fee_category_id(self.id, :conditions => ["start_date < ? AND due_date > ?", Date.today.to_date, Date.today.to_date])
    collection.reject!{ |c| c.no_transaction_present } unless collection.nil?
    collection.present?
  end

  def have_common_particular?
    self.fee_particulars.find_all_by_student_category_id_and_admission_no(nil, nil).count > 0
  end


end
