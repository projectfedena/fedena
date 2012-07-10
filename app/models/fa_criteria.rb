class FaCriteria < ActiveRecord::Base
  has_many    :descriptive_indicators,  :as=>:describable
  has_many    :assessment_scores, :through=>:descriptive_indicators
  accepts_nested_attributes_for :descriptive_indicators
  has_many :cce_reports , :as=>:observable
  belongs_to :fa_group

  default_scope :order=>'sort_order ASC'
  named_scope :active,:conditions=>{:is_deleted=>false}

  validates_presence_of :fa_group_id
  def validate
    errors.add_to_base("Name can't be blank") if self.fa_name.blank?
    errors.add_to_base("Description can't be blank") if self.desc.blank?
  end
end
