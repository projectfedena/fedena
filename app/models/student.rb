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

class Student < ActiveRecord::Base
  belongs_to :country
  belongs_to :batch
  belongs_to :student_category
  belongs_to :nationality, :class_name => 'Country'
  belongs_to :user,:dependent=>:destroy

  has_one    :immediate_contact
  has_one    :student_previous_data
  has_many   :student_previous_subject_mark
  has_many   :guardians, :foreign_key => 'ward_id', :dependent => :destroy
  has_many   :finance_transactions, :as => :payee
  has_many   :attendances
  has_many   :finance_fees
  has_many   :fee_category ,:class_name => "FinanceFeeCategory"
  has_many   :students_subjects
  has_many   :subjects ,:through => :students_subjects

  has_and_belongs_to_many :graduated_batches, :class_name => 'Batch', :join_table => 'batch_students'

  named_scope :active, :conditions => { :is_active => true }

  validates_presence_of :admission_no, :admission_date, :first_name, :batch_id, :date_of_birth
  validates_uniqueness_of :admission_no
  validates_presence_of :gender
  validates_format_of     :email, :with => /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i,   :allow_blank=>true,
    :message => "#{t('must_be_a_valid_email_address')}"
  validates_format_of     :admission_no, :with => /^[A-Z0-9_-]*$/i,
    :message => "#{t('must_contain_only_letters')}"

  validates_associated :user
  before_validation :create_user_and_validate

  has_attached_file :photo,
    :styles => {
    :thumb=> "100x100#",
    :small  => "150x150>"},
    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"

  VALID_IMAGE_TYPES = ['image/gif', 'image/png','image/jpeg', 'image/jpg']

  validates_attachment_content_type :photo, :content_type =>VALID_IMAGE_TYPES,
    :message=>'Image can only be GIF, PNG, JPG',:if=> Proc.new { |p| !p.photo_file_name.blank? }
  validates_attachment_size :photo, :less_than => 512000,\
    :message=>'must be less than 500 KB.',:if=> Proc.new { |p| p.photo_file_name_changed? }

  def validate
    errors.add(:date_of_birth, "#{t('cant_be_a_future_date')}.") if self.date_of_birth >= Date.today \
      unless self.date_of_birth.nil?
    errors.add(:gender, "#{t('model_errors.student.error2')}.") unless ['m', 'f'].include? self.gender.downcase \
      unless self.gender.nil?
    errors.add(:admission_no, "#{t('model_errors.student.error3')}.") if self.admission_no=='0'
    
  end

  def create_user_and_validate
    self.email ||="noreply" + self.admission_no.to_s + "@fedena.com"
    if self.new_record?
      user_record = self.build_user
      user_record.first_name = self.first_name
      user_record.last_name = self.last_name
      user_record.username = self.admission_no.to_s
      user_record.password = self.admission_no.to_s + "123"
      user_record.role = 'Student'
      user_record.email = self.email.blank? ? "noreply#{self.admission_no.to_s}@fedena.com" : self.email.to_s
      check_user_errors(user_record)
      return false unless errors.blank?
    else
      self.user.role = "Student"
      changes_to_be_checked = ['admission_no','first_name','last_name','email']
      check_changes = self.changed & changes_to_be_checked
      unless check_changes.blank?
        self.user.username = self.admission_no if check_changes.include?('admission_no')
        self.user.first_name = self.first_name if check_changes.include?('first_name')
        self.user.last_name = self.last_name if check_changes.include?('last_name')
        self.user.email = self.email if check_changes.include?('email')
        check_user_errors(self.user)
      end
    end
    self.email = "noreply#{self.admission_no}@fedena.com" if self.email.blank?
    return false unless errors.blank?
  end

  def check_user_errors(user)
    unless user.valid?
      user.errors.each{|attr,msg| errors.add(attr.to_sym,"#{msg}")}
    end
    return false unless user.errors.blank?
  end

  def first_and_last_name
    "#{first_name} #{last_name}"
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  def gender_as_text
    return 'Male' if gender.downcase == 'm'
    return 'Female' if gender.downcase == 'f'
    nil
  end

  def all_batches
    self.graduated_batches + self.batch.to_a
  end

  def immediate_contact
    Guardian.find(self.immediate_contact_id) unless self.immediate_contact_id.nil?
  end

  def image_file=(input_data)
    return if input_data.blank?
    self.photo_filename     = input_data.original_filename
    self.photo_content_type = input_data.content_type.chomp
    self.photo_data         = input_data.read
  end

  def next_student
    next_st = self.batch.students.first(:conditions => "id > #{self.id}", :order => "id ASC")
    next_st ||= batch.students.first(:order => "id ASC")
  end

  def previous_student
    prev_st = self.batch.students.first(:conditions => "id < #{self.id}", :order => "admission_no DESC")
    prev_st ||= batch.students.first(:order => "id DESC")
    prev_st ||= self.batch.students.first(:order => "id DESC")
  end

  def previous_fee_student(date)
    fee = FinanceFee.first(:conditions => "student_id < #{self.id} and fee_collection_id = #{date}", :joins=>'INNER JOIN students ON finance_fees.student_id = students.id',:order => "student_id DESC")
    prev_st = fee.student unless fee.blank?
    fee ||= FinanceFee.first(:conditions=>"fee_collection_id = #{date}", :joins=>'INNER JOIN students ON finance_fees.student_id = students.id',:order => "student_id DESC")
    prev_st ||= fee.student unless fee.blank?
    #    prev_st ||= self.batch.students.first(:order => "id DESC")
  end

  def next_fee_student(date)

    fee = FinanceFee.first(:conditions => "student_id > #{self.id} and fee_collection_id = #{date}", :joins=>'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id ASC")
    next_st = fee.student unless fee.nil?
    fee ||= FinanceFee.first(:conditions=>"fee_collection_id = #{date}", :joins=>'INNER JOIN students ON finance_fees.student_id = students.id',:order => "student_id ASC")
    next_st ||= fee.student unless fee.nil?
    #    prev_st ||= self.batch.students.first(:order => "id DESC")
  end

  def finance_fee_by_date(date)
    FinanceFee.find_by_fee_collection_id_and_student_id(date.id,self.id)
  end

  def check_fees_paid(date)
    particulars = date.fees_particulars(self)
    total_fees=0
    financefee = date.fee_transactions(self.id)
    batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(date.id)
    student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(date.id,self.id)
    category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(date.id,self.student_category_id)
    total_discount = 0
    total_discount += batch_discounts.map{|s| s.discount}.sum unless batch_discounts.nil?
    total_discount += student_discounts.map{|s| s.discount}.sum unless student_discounts.nil?
    total_discount += category_discounts.map{|s| s.discount}.sum unless category_discounts.nil?
    if total_discount > 100
      total_discount = 100
    end
    particulars.map { |s|  total_fees += s.amount.to_f}
    total_fees -= total_fees*(total_discount/100)
    paid_fees_transactions = FinanceTransaction.find(:all,:select=>'amount,fine_amount',:conditions=>"FIND_IN_SET(id,\"#{financefee.transaction_id}\")") unless financefee.nil?
    paid_fees = 0
    paid_fees_transactions.map { |m| paid_fees += (m.amount.to_f - m.fine_amount.to_f) } unless paid_fees_transactions.nil?
    amount_pending = total_fees.to_f - paid_fees.to_f
    if amount_pending == 0
      return true
    else
      return false
    end

    #    unless particulars.nil?
    #      return financefee.check_transaction_done unless financefee.nil?
    #
    #    else
    #      return false
    #    end
  end

  def check_fee_pay(date)
    date.finance_fees.first(:conditions=>"student_id = #{self.id}").is_paid
  end

  def self.next_admission_no
    '' #stub for logic to be added later.
  end
  
  def get_fee_strucure_elements(date)
    elements = FinanceFeeStructureElement.get_student_fee_components(self,date)
    elements[:all] + elements[:by_batch] + elements[:by_category] + elements[:by_batch_and_category]
  end

  def total_fees(particulars)
    total = 0
    particulars.each do |fee|
      total += fee.amount
    end
    total
  end

  def archive_student(status)
    self.update_attributes(:is_active => false, :status_description => status)
    student_attributes = self.attributes
    student_attributes["former_id"]= self.id
    student_attributes.delete "id"
    student_attributes.delete "has_paid_fees"
    student_attributes.delete "photo_file_size"
    student_attributes.delete "photo_file_name"
    student_attributes.delete "photo_content_type"
    student_attributes.delete "user_id"
    archived_student = ArchivedStudent.new(student_attributes)
    archived_student.photo = self.photo
    if archived_student.save
      guardian = self.guardians
      self.user.destroy unless self.user.blank?
      self.destroy
      guardian.each do |g|
        g.archive_guardian(archived_student.id)
      end
      #
      student_exam_scores = ExamScore.find_all_by_student_id(self.id)
      student_exam_scores.each do |s|
        exam_score_attributes = s.attributes
        exam_score_attributes.delete "id"
        exam_score_attributes.delete "student_id"
        exam_score_attributes["student_id"]= archived_student.id
        ArchivedExamScore.create(exam_score_attributes)
        s.destroy
      end
      #
    end
 
  end
  
  def check_dependency
    flag = false
    flag = true unless self.finance_transactions.blank?
    flag = true unless self.graduated_batches.blank?
    flag = true unless self.attendances.blank?
    flag = true unless self.finance_fees.blank?
    plugin_dependencies = FedenaPlugin.check_dependency(self,"permanant")
    plugin_dependencies.each do |k,v|
      if v.kind_of?(Array)
        flag=true unless  v.blank?
      else
         v.each do |h,a|
           flag=true unless  a.blank?
         end
      end
    end
    return flag
  end

  def former_dependency
   plugin_dependencies = FedenaPlugin.check_dependency(self,"former")
  end
end
