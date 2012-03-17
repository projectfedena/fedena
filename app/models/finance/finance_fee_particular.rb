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

class FinanceFeeParticular < ActiveRecord::Base

  belongs_to :finance_fee_category
  belongs_to :student_category
  validates_presence_of :name,:amount
  validates_numericality_of :amount, :greater_than_or_equal_to => 0, :message => "#{t('must_be_positive')}"
  cattr_reader :per_page
  @@per_page = 10
  
  def deleted_category
    flag = false
    category = self.student_category
    unless category.blank?
      flag = true if category.is_deleted
    end
    return flag
  end

end
