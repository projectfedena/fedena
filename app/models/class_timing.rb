class ClassTiming < ActiveRecord::Base
  has_many :timetable_entries , :dependent => :destroy
  belongs_to :batch

  validates_presence_of :name
  validates_uniqueness_of :name,  :scope => :batch_id

  named_scope :for_batch, lambda { |b| { :conditions => { :batch_id => b.to_i },  :order =>'start_time ASC' } }
  named_scope :default, :conditions => { :batch_id => nil, :is_break => false }, :order =>'start_time ASC'

  def validate
    errors.add(:end_time, "should be later than start time.") \
      if self.start_time > self.end_time \
      unless self.start_time.nil? or self.end_time.nil?
    start_overlap = !ClassTiming.find(:first, :conditions=>["start_time < ? and end_time > ? and batch_id #{self.batch_id.nil? ? 'is null' : '='+ self.batch_id.to_s}", self.start_time,self.start_time]).nil?
    end_overlap = !ClassTiming.find(:first, :conditions=>["start_time < ? and end_time > ? and batch_id #{self.batch_id.nil? ? 'is null' : '='+ self.batch_id.to_s}", self.end_time,self.end_time]).nil?
    errors.add(:start_time, "overlaps existing class timing.") if start_overlap
    errors.add(:end_time, "overlaps existing class timing.") if end_overlap
    errors.add(:start_time,"is same as end time") if self.start_time == self.end_time
  end
end
