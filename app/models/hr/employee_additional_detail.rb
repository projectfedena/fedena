class EmployeeAdditionalDetail < ActiveRecord::Base
  belongs_to :employee
  belongs_to :additional_field
  
  def archive_employee_additional_detail(archived_employee)
    additional_detail_attributes = self.attributes
    additional_detail_attributes.delete "id"
    additional_detail_attributes["employee_id"] = archived_employee
    self.delete if ArchivedEmployeeAdditionalDetail.create(additional_detail_attributes)
  end
end
