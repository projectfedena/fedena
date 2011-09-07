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

class Xml < ActiveRecord::Base

  class << self
  def get_ledger_name(key)
      c = find_by_finance_name(key)
      c.nil? ? nil : c.ledger_name
    end
def set_value(key, value)
      @xml = find_by_finance_name(key)
      @xml.nil? ?
        Xml.create(:finance_name => key, :ledger_name => value) :
        @xml.update_attribute(:ledger_name, value)
    end
  def set_ledger_name(values_hash)
      values_hash.each_pair { |key, value| set_value(key.to_s, value) }
    end
  def get_multiple_finance_as_hash(keys)
      conf_hash = {}
      keys.each { |k| conf_hash[k.underscore.to_sym] = get_ledger_name(k) }
      conf_hash
    end
  end
end
