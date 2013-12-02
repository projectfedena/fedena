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
class Student < ActiveRecord::Base

  include CceReportMod

  belongs_to :country
  belongs_to :batch
  belongs_to :student_category
  belongs_to :nationality, :class_name => 'Country'
  belongs_to :user

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
  has_many   :student_additional_details
  has_many   :batch_students
  has_many   :subject_leaves
  has_many   :grouped_exam_reports
  has_many   :cce_reports
  has_many   :assessment_scores
  has_many   :exam_scores
  has_many   :previous_exam_scores

  validates_presence_of :admission_no, :admission_date, :first_name, :batch_id, :date_of_birth
  validates_uniqueness_of :admission_no
  validates_presence_of :gender
  validates_inclusion_of :gender, :in => %w( m f M F ), :message => "#{t('model_errors.student.error2')}."
  validates_format_of   :email, :with => /\A[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}\z/i,   :allow_blank=>true,
    :message => "#{t('must_be_a_valid_email_address')}"
  validates_format_of     :admission_no, :with => /\A[A-Z0-9_-]*\z/i,
    :message => "#{t('must_contain_only_letters')}"

  validate :date_of_birth_must_not_be_future, :check_admission_no
  validates_associated :user

  before_validation :create_user_and_validate
  before_save :is_active_true

  has_attached_file :photo,
    :styles => {:original=> "125x125#"},
    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"

  VALID_IMAGE_TYPES = ['image/gif', 'image/png','image/jpeg', 'image/jpg']

  validates_attachment_content_type :photo, :content_type =>VALID_IMAGE_TYPES,
    :message=>'Image can only be GIF, PNG, JPG',:if=> Proc.new { |p| !p.photo_file_name.blank? }
  validates_attachment_size :photo, :less_than => 512000,\
    :message=>'must be less than 500 KB.',:if=> Proc.new { |p| p.photo_file_name_changed? }

  named_scope :active, :conditions => { :is_active => true }
  named_scope :with_full_name_only, :select => "id, CONCAT_WS('', first_name, ' ', last_name) AS name, first_name, last_name", :order => :first_name
  named_scope :with_name_admission_no_only, :select => "id, CONCAT_WS('', first_name, ' ', last_name, ' - ', admission_no) AS name, first_name, last_name, admission_no", :order => :first_name
  named_scope :by_first_name, :order => 'first_name', :conditions => { :is_active => true }

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
    case gender.downcase
      when 'm' then 'Male'
      when 'f' then 'Female'
      else nil
    end
  end

  def graduated_batches
    self.batch_students.map{|bt| bt.batch}
  end

  def all_batches
    self.graduated_batches << self.batch
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
    next_st = self.batch.students.first(:conditions => ["id > ?", self.id], :order => "id ASC")
    next_st ||= self.batch.students.first(:order => "id ASC")
  end

  def previous_student
    prev_st = self.batch.students.first(:conditions => ["id < ?", self.id], :order => "admission_no DESC")
    prev_st ||= self.batch.students.first(:order => "id DESC")
  end

  def previous_fee_student(date)
    fee = FinanceFee.first(:conditions => ["student_id < ? AND fee_collection_id = ?", self.id, date], :joins => 'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id DESC")
    prev_st = fee.student if fee.present?
    fee ||= FinanceFee.find_by_fee_collection_id(date, :joins => 'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id DESC")
    prev_st ||= fee.student if fee.present?
    #    prev_st ||= self.batch.students.first(:order => "id DESC")
  end

  def next_fee_student(date)

    fee = FinanceFee.first(:conditions => ["student_id > ? AND fee_collection_id = ?", self.id, date], :joins => 'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id ASC")
    next_st = fee.student unless fee.nil?
    fee ||= FinanceFee.find_by_fee_collection_id(date, :joins => 'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id ASC")
    next_st ||= fee.student unless fee.nil?
    #    prev_st ||= self.batch.students.first(:order => "id DESC")
  end

  def finance_fee_by_date(date)
    FinanceFee.find_by_fee_collection_id_and_student_id(date.id,self.id)
  end

  def check_fees_paid(date)
    particulars = date.fees_particulars(self)
    total_fees = 0
    financefee = date.fee_transactions(self.id)
    batch_discounts = BatchFeeCollectionDiscount.find_all_by_finance_fee_collection_id(date.id)
    student_discounts = StudentFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(date.id, self.id)
    category_discounts = StudentCategoryFeeCollectionDiscount.find_all_by_finance_fee_collection_id_and_receiver_id(date.id, self.student_category_id)
    total_discount = 0
    total_discount += batch_discounts.map{ |s| s.discount }.sum if batch_discounts.present?
    total_discount += student_discounts.map{ |s| s.discount }.sum if student_discounts.present?
    total_discount += category_discounts.map{ |s| s.discount }.sum if category_discounts.present?
    if total_discount > 100
      total_discount = 100
    end
    particulars.map { |s|  total_fees += s.amount.to_f}
    total_fees -= total_fees * (total_discount / 100)
    paid_fees_transactions = FinanceTransaction.find(:all,:select=>'amount, fine_amount', :conditions => ["FIND_IN_SET(id, ?)", financefee.transaction_id]) unless financefee.nil?
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

  def has_retaken_exam?(subject_id)
    retaken_exams = PreviousExamScore.find_all_by_student_id(self.id)
    if retaken_exams.any?
      exams = Exam.find_all_by_id(retaken_exams.collect(&:exam_id))
      if exams.collect(&:subject_id).include?(subject_id)
        return true
      end
    end
  end

  def check_fee_pay(date)
    date.finance_fees.first(:conditions => ["student_id = ?", self.id]).is_paid
  end

  def self.next_admission_no
    '' #stub for logic to be added later.
  end

  def get_fee_strucure_elements(date)
    elements = FinanceFeeStructureElement.get_student_fee_components(self, date)
    elements[:all] + elements[:by_batch] + elements[:by_category] + elements[:by_batch_and_category]
  end

  def total_fees(particulars)
    particulars.inject(0) { |total, fee| total + fee.amount }
  end

  def has_associated_fee_particular?(fee_category)
    fee_category.fee_particulars.find_all_by_admission_no(admission_no).count > 0 \
    || student_category_id.present? && fee_category.fee_particulars.find_all_by_student_category_id(student_category_id).count > 0
  end

  def archive_student(status)
    student_attributes = self.attributes
    student_attributes["former_id"] = self.id
    student_attributes["status_description"] = status
    student_attributes.delete "id"
    student_attributes.delete "has_paid_fees"
    student_attributes.delete "created_at"
    archived_student = ArchivedStudent.new(student_attributes)
    archived_student.photo = self.photo
    if archived_student.save
      guardians = self.guardians
      self.user.soft_delete
      guardians.each do |g|
        g.archive_guardian(archived_student.id)
      end
      self.destroy
      #
      #      student_exam_scores = ExamScore.find_all_by_student_id(self.id)
      #      student_exam_scores.each do |s|
      #        exam_score_attributes = s.attributes
      #        exam_score_attributes.delete "id"
      #        exam_score_attributes.delete "student_id"
      #        exam_score_attributes["student_id"]= archived_student.id
      #        ArchivedExamScore.create(exam_score_attributes)
      #        s.destroy
      #      end
      #
    end

  end

  def check_dependency
    self.finance_transactions.present? || self.graduated_batches.present? || self.attendances.present? || self.finance_fees.present? || FedenaPlugin.check_dependency(self,"permanant").present?
  end

  def former_dependency
    plugin_dependencies = FedenaPlugin.check_dependency(self,"former")
  end

  def assessment_score_for(indicator_id, exam_id, batch_id)
    self.assessment_scores.find_by_student_id_and_descriptive_indicator_id_and_exam_id_and_batch_id(self.id, indicator_id, exam_id, batch_id) \
    || assessment_scores.build(:descriptive_indicator_id => indicator_id, :exam_id => exam_id, :batch_id => batch_id)
  end

  def observation_score_for(indicator_id, batch_id)
    self.assessment_scores.find_by_student_id_and_descriptive_indicator_id_and_batch_id(self.id, indicator_id, batch_id) \
    || assessment_scores.build(:descriptive_indicator_id => indicator_id, :batch_id => batch_id)
  end

  def has_higher_priority_ranking_level(ranking_level_id, type, subject_id)
    ranking_level = RankingLevel.find(ranking_level_id)
    higher_levels = RankingLevel.find(:all, :conditions=>["course_id = ? AND priority < ?", ranking_level.course_id, ranking_level.priority])
    if higher_levels.empty?
      return false
    else
      higher_levels.each do|level|
        if type == "subject"
          score = GroupedExamReport.find_by_student_id_and_subject_id_and_batch_id_and_score_type(self.id,subject_id,self.batch_id,"s")
          return true if score.present? && check_score_marks(score.marks, level)

        elsif type == "overall"
          if level.subject_count.present?
            if level.full_course == false
              subjects = self.batch.subjects
              scores = GroupedExamReport.find_all_by_student_id_and_batch_id_and_subject_id_and_score_type(self.id, self.batch.id, subjects.collect(&:id), 's')
            else
              scores = GroupedExamReport.find_all_by_student_id_and_score_type(self.id, 's')
            end
            if scores.any?
              scores = reject_scores(scores, level)
              return true if scores.any? && check_scores_count_and_subject_count(level.subject_limit_type, scores.count, level.subject_count)
            end
          else
            if level.full_course == false
              score = GroupedExamReport.find_by_student_id_and_batch_id_and_score_type(self.id, self.batch.id, 'c')
            else
              total_student_score = 0
              avg_student_score = 0
              marks = GroupedExamReport.find_all_by_student_id_and_score_type(self.id, 'c')
              if marks.any?
                marks.map{|m| total_student_score += m.marks}
                avg_student_score = total_student_score.to_f / marks.count.to_f
                marks.first.marks = avg_student_score
                score = marks.first
              end
            end
            return true if score.present? && check_score_marks(score.marks, level)
          end
        elsif type == "course"
          if level.subject_count.present?
            scores = GroupedExamReport.find_all_by_student_id_and_score_type(self.id, 's')

            if scores.any?
              scores = reject_scores(scores, level)

              if scores.any?
                if level.full_course == false
                  batch_ids = scores.collect(&:batch_id)
                  batch_ids.each do|batch_id|
                    if batch_ids.any?
                      count = batch_ids.count(batch_id)
                      return true if check_scores_count_and_subject_count(level.subject_limit_type, count, level.subject_count)
                      batch_ids.delete(batch_id)
                    end
                  end
                else
                  return true if check_scores_count_and_subject_count(level.subject_limit_type, scores.count, level.subject_count)
                end
              end
            end
          else
            if level.full_course == false
              scores = GroupedExamReport.find_all_by_student_id_and_score_type(self.id, 'c')
              if scores.any?
                scores = reject_scores(scores, level)
                return true if scores.any?
              end
            else
              total_student_score = 0
              avg_student_score = 0
              marks = GroupedExamReport.find_all_by_student_id_and_score_type(self.id, 'c')
              if marks.any?
                marks.map{|m| total_student_score += m.marks}
                avg_student_score = total_student_score.to_f / marks.count.to_f
                return true if check_score_marks(avg_student_score, level)
              end
            end
          end
        end
      end
    end
    return false
  end

  private

  def date_of_birth_must_not_be_future
    errors.add(:date_of_birth, "#{t('cant_be_a_future_date')}.") if self.date_of_birth.present? && self.date_of_birth >= Date.current
  end

  def check_admission_no
    errors.add(:admission_no, "#{t('model_errors.student.error3')}.") if self.admission_no == '0'
    errors.add(:admission_no, "#{t('should_not_be_admin')}") if self.admission_no.to_s.downcase == 'admin'
  end

  def is_active_true
    self.is_active = true if self.is_active == false
  end

  def create_user_and_validate
    if self.new_record?
      user_record = self.build_user
      user_record.first_name = self.first_name
      user_record.last_name = self.last_name
      user_record.username = self.admission_no.to_s
      user_record.password = self.admission_no.to_s + "123"
      user_record.role = 'Student'
      user_record.email = self.email.blank? ? "" : self.email.to_s
      check_user_errors(user_record)
    else
      self.user.role = "Student"
      changes_to_be_checked = ['admission_no','first_name','last_name','email','immediate_contact_id']
      check_changes = self.changed & changes_to_be_checked
      if check_changes.any?
        self.user.username = self.admission_no if check_changes.include?('admission_no')
        self.user.first_name = self.first_name if check_changes.include?('first_name')
        self.user.last_name = self.last_name if check_changes.include?('last_name')
        self.user.email = self.email if check_changes.include?('email')
        check_user_errors(self.user)
        if check_changes.include?('immediate_contact_id') || check_changes.include?('admission_no')
          Guardian.shift_user(self)
        end
      end
    end
    self.email = "" if self.email.blank?
    return false unless errors.blank?
  end

  def check_score_marks(score_marks, level)
    if self.batch.gpa_enabled?
      return true if (score_marks < level.gpa && level.marks_limit_type == 'upper') || (score_marks >= level.gpa && level.marks_limit_type == 'lower') || (score_marks == level.gpa && level.marks_limit_type == 'exact')
    else
      return true if (score_marks < level.marks && level.marks_limit_type == 'upper') || (score_marks >= level.marks && level.marks_limit_type == 'lower') || (score_marks == level.marks && level.marks_limit_type == 'exact')
    end
  end

  def reject_scores(scores, level)
    if self.batch.gpa_enabled?
      scores.reject{ |s| !((s.marks < level.gpa && level.marks_limit_type == 'upper') || (s.marks >= level.gpa && level.marks_limit_type == 'lower') || (s.marks == level.gpa && level.marks_limit_type == 'exact')) }
    else
      scores.reject{ |s| !((s.marks < level.marks && level.marks_limit_type == 'upper') || (s.marks >= level.marks && level.marks_limit_type == 'lower') || (s.marks == level.marks && level.marks_limit_type == 'exact')) }
    end
  end

  def check_scores_count_and_subject_count(subject_limit_type, scores_count, subject_count)
    return true if (scores_count < subject_count && subject_limit_type == 'upper') || (scores_count >= subject_count && subject_limit_type == 'lower') || (scores_count == subject_count && subject_limit_type == 'exact')
  end

end
