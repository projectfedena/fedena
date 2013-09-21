class School < ActiveRecord::Base
  has_one :school_details
  has_one :additional_field_option
end
