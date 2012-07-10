class Observation < ActiveRecord::Base
  belongs_to  :observation_group
  has_many    :descriptive_indicators,  :as=>:describable
  has_many    :assessment_scores, :through=>:descriptive_indicators
  accepts_nested_attributes_for :descriptive_indicators
  has_many    :cce_reports, :as=>:observable

  default_scope :order=>'sort_order ASC'
  named_scope :active,:conditions=>{:is_active=>true}

  def next_record
    observation_group.observations.first(:conditions => ['order > ?',order])
  end
  def prev_record
    observation_group.observations.last(:conditions => ['order < ?',order])
  end

  def validate
    errors.add_to_base("Name can't be blank") if self.name.blank?
    errors.add_to_base("Description can't be blank") if self.desc.blank? 
  end
end
