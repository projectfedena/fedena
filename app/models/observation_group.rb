class ObservationGroup < ActiveRecord::Base
  has_many                  :observations
  has_many                  :descriptive_indicators, :through=>:observations
  belongs_to                :cce_grade_set
  has_and_belongs_to_many   :courses
  
  OBSERVATION_KINDS={'0'=>'Scholastic','1'=>'Co Scholastic Activity','3'=>'Co Scholastic Area'}

  validates_presence_of :name
  validates_presence_of :header_name
  validates_presence_of :desc,:cce_grade_set_id,:observation_kind #,:max_marks
end
