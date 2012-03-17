class AddFieldsToPrivilege < ActiveRecord::Migration
  def self.up
    add_column :privileges, :description, :text
    create_defaults
  end

  def self.down
    remove_column :privileges, :description
  end
  
  def self.create_defaults
    Privilege.reset_column_information
    Privilege.create :name => 'ExaminationControl' , :description => 'Examination Control'
    Privilege.create :name => 'EnterResults' , :description => 'Enter Results'
    Privilege.create :name => 'ViewResults' , :description => 'View Results'
    Privilege.create :name => 'Admission' , :description => 'Admission'
    Privilege.create :name => 'StudentsControl' , :description => 'Students Control'
    Privilege.create :name => 'ManageNews' , :description => 'Manage News'
    Privilege.create :name => 'ManageTimetable' , :description => 'Manage Timetable'
    Privilege.create :name => 'StudentAttendanceView' , :description => 'Student Attendance View'
    Privilege.create :name => 'HrBasics' , :description => 'Hr Basics'
    Privilege.create :name => 'AddNewBatch' , :description => 'Add New Batch'
    Privilege.create :name => 'SubjectMaster' , :description => 'Subject Master'
    Privilege.create :name => 'EventManagement' , :description => 'Event Management'
    Privilege.create :name => 'GeneralSettings' , :description => 'General Settings'
    Privilege.create :name => 'FinanceControl' , :description => 'Finance Control'
    Privilege.create :name => 'TimetableView' , :description => 'Timetable View'
    Privilege.create :name => 'StudentAttendanceRegister' , :description => 'Student Attendance Register'
    Privilege.create :name => 'EmployeeAttendance' , :description => 'Employee Attendance'
    Privilege.create :name => 'PayslipPowers' , :description => 'Payslip Powers'
    Privilege.create :name => 'EmployeeSearch' , :description => 'Employee Search'
    Privilege.create :name => 'SMSManagement' , :description => 'Sms Management'
  end

end
