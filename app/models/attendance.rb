class Attendance < ActiveRecord::Base
  belongs_to :subject
  belongs_to :student
  belongs_to :period_entry, :foreign_key => :period_table_entry_id
  validates_uniqueness_of :student_id, :scope => [:period_table_entry_id]
  validates_presence_of :reason

  def validate
    errors.add("Attendance before the date of admission")  if self.period_entry.month_date < self.student.admission_date
  end
end
