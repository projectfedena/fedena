class Observation < ActiveRecord::Base
  belongs_to  :observation_group
  has_many    :descriptive_indicators,  :as=>:describable
  has_many    :assessment_scores, :through=>:descriptive_indicators
  accepts_nested_attributes_for :descriptive_indicators
  has_many    :cce_reports, :as=>:observable

  validates_presence_of :name,  :desc

  def next_record
    observation_group.observations.first(:conditions => ['order > ?',order])
  end
  def prev_record
    observation_group.observations.last(:conditions => ['order < ?',order])
  end
end
