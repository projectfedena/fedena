class Language < ActiveRecord::Base
 named_scope :translation_available, :conditions => { :code => Configuration::LOCALES }
end
