class SubjectLeave < ActiveRecord::Base
  belongs_to :student
  belongs_to :batch
  named_scope :by_month_and_subject, lambda { |d,s| { :conditions  => { :month_date  => d.beginning_of_month..d.end_of_month , :subject_id => s} } }
  named_scope :by_month_batch_subject, lambda { |d,b,s| {  :conditions  => { :month_date  => d.beginning_of_month..d.end_of_month , :subject_id => s,:batch_id=>b} } }
  def validate
    errors.add("#{t('attendance_before_the_date_of_admission')}")  if self.month_date < self.student.admission_date
  end
  def validate
    errors.add("#{t('attendance_before_the_date_of_admission')}")  if self.month_date < self.student.admission_date
  end
end
