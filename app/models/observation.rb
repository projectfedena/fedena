#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
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
