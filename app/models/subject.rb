class Subject < ActiveRecord::Base

  belongs_to :batch
  belongs_to :elective_group
  has_many :timetable_entries
  validates_presence_of :name, :max_weekly_classes, :code
  validates_numericality_of :max_weekly_classes

  named_scope :for_batch, lambda { |b| { :conditions => { :batch_id => b.to_i, :is_deleted => false } } }
  named_scope :without_exams, :conditions => { :no_exams => false, :is_deleted => false }

  def inactivate
    update_attribute(:is_deleted, true)
  end

end
