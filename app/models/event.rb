class Event < ActiveRecord::Base
  validates_presence_of :title, :description, :start_date, :end_date

  named_scope :holidays, :conditions => {:is_holiday => true}
  named_scope :exams, :conditions => {:is_exam => true}
  has_many :batch_events, :dependent => :destroy
  has_many :employee_department_events, :dependent => :destroy


   def validate
     unless self.start_date.nil? or self.end_date.nil?
       errors.add(:end_time, "can not be before the start time") if self.end_date < self.start_date
     end
   end
  class << self
    def is_a_holiday?(day)
      return true if Event.holidays.count(:all, :conditions => ["start_date <=? AND end_date >= ?", day, day] ) > 0
      false
    end
  end

  
end
