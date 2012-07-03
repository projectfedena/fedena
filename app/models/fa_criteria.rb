class FaCriteria < ActiveRecord::Base
  has_many    :descriptive_indicators,  :as=>:describable
  has_many    :assessment_scores, :through=>:descriptive_indicators
  accepts_nested_attributes_for :descriptive_indicators
  has_many :cce_reports , :as=>:observable
  belongs_to :fa_group
  validates_presence_of :fa_name,:desc,:fa_group_id
end
