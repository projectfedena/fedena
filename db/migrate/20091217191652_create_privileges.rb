class CreatePrivileges < ActiveRecord::Migration
  def self.up
    create_table :privileges do |t|
      t.string :name
      t.timestamps
    end

    Privilege.create :name => "ExaminationControl"
    Privilege.create :name => "EnterResults"
    Privilege.create :name => "ViewResults"
    Privilege.create :name => "Admission"
    Privilege.create :name => "StudentsControl"
    Privilege.create :name => "ManageNews"
    Privilege.create :name => "ManageTimetable"
    Privilege.create :name => "StudentAttendanceView"
    Privilege.create :name => "HrBasics"
    Privilege.create :name => "AddNewBatch"
    Privilege.create :name => "SubjectMaster"
    Privilege.create :name => "EventManagement"
    Privilege.create :name => "GeneralSettings"
    Privilege.create :name => "FinanceControl"
    Privilege.create :name => "TimetableView"
    Privilege.create :name => "StudentAttendanceRegister"
    Privilege.create :name => "EmployeeAttendance"
    Privilege.create :name => "PayslipPowers"
    Privilege.create :name => "EmployeeSearch"
    Privilege.create :name => "SMSManagement"
  end

  def self.down
    drop_table :privileges
  end
end
