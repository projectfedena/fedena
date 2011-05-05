class ArchivedEmployeeAdditionalDetail < ActiveRecord::Base
  belongs_to :archived_employee
  belongs_to :additional_field
end
