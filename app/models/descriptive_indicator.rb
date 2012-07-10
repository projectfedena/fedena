class DescriptiveIndicator < ActiveRecord::Base
  belongs_to    :describable,:polymorphic=>true
  has_many      :assessment_scores
  validates_presence_of :name
  validates_presence_of :desc

  default_scope :order=>'sort_order ASC'
end
