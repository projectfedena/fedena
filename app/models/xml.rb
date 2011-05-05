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
