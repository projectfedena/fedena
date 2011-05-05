class Weekday < ActiveRecord::Base
  belongs_to :batch
 has_many :timetable_entries , :dependent=>:destroy
  default_scope :order => 'weekday asc'
  named_scope   :default, :conditions => { :batch_id => nil}
  named_scope   :for_batch, lambda { |b| { :conditions => { :batch_id => b.to_i } } }
end
