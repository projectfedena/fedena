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
    Privilege.create :name => 'ExaminationControl' , :description => 'examination_control_privilege'
    Privilege.create :name => 'EnterResults' , :description => 'enter_results_privilege'
    Privilege.create :name => 'ViewResults' , :description => 'view_results_privilege'
    Privilege.create :name => 'Admission' , :description => 'admission_privilege'
    Privilege.create :name => 'StudentsControl' , :description => 'students_control_privilege'
    Privilege.create :name => 'ManageNews' , :description => 'manage_news_privilege'
    Privilege.create :name => 'ManageTimetable' , :description => 'manage_timetable_privilege'
    Privilege.create :name => 'StudentAttendanceView' , :description => 'student_attendance_view_privilege'
    Privilege.create :name => 'HrBasics' , :description => 'hr_basics_privilege'
    Privilege.create :name => 'AddNewBatch' , :description => 'add_new_batch_privilege'
    Privilege.create :name => 'SubjectMaster' , :description => 'subject_master_privilege'
    Privilege.create :name => 'EventManagement' , :description => 'event_management_privilege'
    Privilege.create :name => 'GeneralSettings' , :description => 'general_settings_privilege'
    Privilege.create :name => 'FinanceControl' , :description => 'finance_control_privilege'
    Privilege.create :name => 'TimetableView' , :description => 'timetable_view_privilege'
    Privilege.create :name => 'StudentAttendanceRegister' , :description => 'student_attendance_register_privilege'
    Privilege.create :name => 'EmployeeAttendance' , :description => 'employee_attendance_privilege'
    Privilege.create :name => 'PayslipPowers' , :description => 'payslip_powers_privilege'
    Privilege.create :name => 'EmployeeSearch' , :description => 'employee_search_privilege'
    Privilege.create :name => 'SMSManagement' , :description => 'sms_management_privilege'
  end

end
