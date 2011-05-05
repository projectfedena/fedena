class ArchivedEmployeeBankDetail < ActiveRecord::Base
  belongs_to :archived_employee
  belongs_to :bank_field
end
