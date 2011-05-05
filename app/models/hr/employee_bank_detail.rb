class EmployeeBankDetail < ActiveRecord::Base
  belongs_to :employee
  belongs_to :bank_field

  def archive_employee_bank_detail(archived_employee)
    bank_detail_attributes = self.attributes
    bank_detail_attributes.delete "id"
    bank_detail_attributes["employee_id"] = archived_employee
    self.delete if ArchivedEmployeeBankDetail.create(bank_detail_attributes)
  end
end
