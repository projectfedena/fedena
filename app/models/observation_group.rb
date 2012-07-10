class ObservationGroup < ActiveRecord::Base
  has_many                  :observations
  has_many                  :descriptive_indicators, :through=>:observations
  belongs_to                :cce_grade_set
  has_and_belongs_to_many   :courses

  named_scope :active,:conditions=>{:is_deleted=>false}
  
  OBSERVATION_KINDS={'0'=>'Scholastic','1'=>'Co Scholastic Activity','3'=>'Co Scholastic Area'}

  validates_presence_of :name
  validates_presence_of :header_name
  validates_presence_of :observation_kind #,:max_marks
  def validate
    errors.add_to_base("CCE grade set can't be blank") if self.cce_grade_set_id.blank?
    errors.add_to_base("Description can't be blank") if self.desc.blank?
  end
end
