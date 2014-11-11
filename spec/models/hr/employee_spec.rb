require 'spec_helper'

describe Employee do

  it { should belong_to(:employee_category) }
  it { should belong_to(:employee_position) }
  it { should belong_to(:employee_grade) }
  it { should belong_to(:employee_department) }
  it { should belong_to(:nationality).class_name('Country') }
  it { should belong_to(:user) }
  it { should belong_to(:reporting_manager).class_name('Employee') }

  it { should have_many(:employees_subjects) }
  it { should have_many(:subjects).through(:employees_subjects) }
  it { should have_many(:timetable_entries) }
  it { should have_many(:employee_bank_details) }
  it { should have_many(:employee_additional_details) }
  it { should have_many(:apply_leaves) }
  it { should have_many(:monthly_payslips) }
  it { should have_many(:employee_salary_structures) }
  it { should have_many(:finance_transactions) }
  it { should have_many(:employee_attendances) }

  context 'a exists record' do
    subject { FactoryGirl.create(:employee) }

    #it { should validate_uniqueness_of(:employee_number) }
    it { should validate_presence_of(:employee_category_id) }
    it { should validate_presence_of(:employee_number) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:employee_position_id) }
    it { should validate_presence_of(:employee_department_id) }
    it { should validate_presence_of(:date_of_birth) }
    it { should validate_presence_of(:joining_date) }
    it { should validate_presence_of(:nationality_id) }
    it { should validate_format_of(:email).not_with('test@test').with_message(I18n.t('must_be_a_valid_email_address')) }
  end

  describe '#status_true' do
    let(:employee) { FactoryGirl.build(:employee, :status => false) }

    it 'does update status to true' do
      employee.status_true
      employee.status.should == true
    end
  end

  describe '#create_user_and_validate' do
    context 'employee is new record' do
      let(:employee) { FactoryGirl.build(:employee, :first_name => 'FN', :last_name => 'LN', :employee_number => 20) }

      context 'create user and validate' do
        context 'email is present' do
          before do
            employee.email = 'admin@fedena.com'
            employee.create_user_and_validate
          end

          it 'does update user.first_name' do
            employee.user.first_name.should == 'FN'
          end

          it 'does update user.last_name' do
            employee.user.last_name.should == 'LN'
          end

          it 'does update user.username' do
            employee.user.username.should == '20'
          end

          it 'does update user.password' do
            employee.user.password.should == '20123'
          end

          it 'does update user.role' do
            employee.user.role.should == 'Employee'
          end

          it 'does update user.email' do
            employee.user.email.should == 'admin@fedena.com'
          end
        end

        context 'email is blank' do
          before do
            employee.email = ''
            employee.create_user_and_validate
          end

          it 'does update user.email' do
            employee.user.email.should == ''
          end
        end

        context 'check_user_errors is true' do
          before { employee.stub(:check_user_errors).and_return(true) }

          it 'returns true' do
            employee.create_user_and_validate.should be_true
          end
        end

        context 'check_user_errors is false' do
          before { employee.stub(:check_user_errors).and_return(false) }

          it 'returns false' do
            employee.create_user_and_validate.should be_false
          end
        end

      end
    end


    context 'employee is not new record' do
      let(:employee) { FactoryGirl.create(:employee, :first_name => 'FN', :last_name => 'LN', :employee_number => 20, :email => 'admin@fedena.com') }

      context 'check_changes is any' do
        context 'check_changes include employee_number, first_name, last_name, email' do
          before { employee.stub(:changed).and_return(['employee_number','first_name','last_name','email']) }

          context 'check_user_errors is true' do
            before { employee.stub(:check_user_errors).and_return(true) }

            it 'does save user' do
              employee.user.should_receive(:save)
              employee.create_user_and_validate
            end

            context 'update user data' do
              before { employee.create_user_and_validate }

              it 'does update user.first_name' do
                employee.user.first_name.should == 'FN'
              end

              it 'does update user.last_name' do
                employee.user.last_name.should == 'LN'
              end

              it 'does update user.username' do
                employee.user.username.should == '20'
              end

              it 'does update user.password' do
                employee.user.password.should == '20123'
              end

              it 'does update user.email' do
                employee.user.email.should == 'admin@fedena.com'
              end
            end
          end

          context 'check_user_errors is false' do
            before { employee.stub(:check_user_errors).and_return(false) }

            it 'does not save user' do
              employee.user.should_not_receive(:save)
              employee.create_user_and_validate
            end
          end
        end
      end
    end
  end


  describe '#check_user_errors' do
    let(:employee) { FactoryGirl.create(:employee) }
    let(:user) { FactoryGirl.create(:admin_user) }

    context 'user is valid and user.errors is empty' do
      before do
        user.stub(:valid?).and_return(true)
        user.stub(:errors).and_return({})
      end

      it 'returns true' do
        employee.check_user_errors(user).should be_true
      end
    end

    context 'user is invalid and user.errors is present' do
      before do
        user.stub(:valid?).and_return(false)
        user.stub(:errors).and_return({:base => 'sample errors'})
      end

      it 'returns false' do
        employee.check_user_errors(user).should be_false
      end
    end
  end

  describe '#employee_batches' do
    let(:employee) { FactoryGirl.create(:employee, :id => '5') }

    context 'found Batch.active with employee_id' do
      let(:batch) { FactoryGirl.build(:batch, :employee_id => '5') }
      before { Batch.stub(:active).and_return([batch]) }

      context 'batch.employee_id = employee.id' do
        it 'returns all batch' do
          employee.employee_batches.should == [batch]
        end
      end
    end
  end

  describe '#max_hours_per_day' do
    let(:employee_grade) { FactoryGirl.build(:employee_grade, :max_hours_day => 33) }
    let(:employee) { FactoryGirl.create(:employee, :employee_grade => employee_grade) }

    it 'returns max_hours_day' do
      employee.max_hours_per_day.should == 33
    end
  end

  describe '#max_hours_per_week' do
    let(:employee_grade) { FactoryGirl.build(:employee_grade, :max_hours_week => 44) }
    let(:employee) { FactoryGirl.create(:employee, :employee_grade => employee_grade) }

    it 'returns max_hours_day' do
      employee.max_hours_per_week.should == 44
    end
  end

  describe '#next_employee' do
    let(:employee1) { FactoryGirl.build(:employee) }
    let(:employee_department) { FactoryGirl.build(:employee_department, :employees => [employee1]) }
    let(:employee) { FactoryGirl.build(:employee, :employee_department => employee_department) }

    context 'found employee with id > employee.id' do
      before { employee_department.employees.stub(:first).with(:conditions => ["id > ?", employee.id], :order => "id ASC").and_return(employee1) }

      it 'returns next_employee' do
        employee.next_employee.should == employee1
      end
    end

    context 'not found employee with id > employee.id' do
      before { employee_department.employees.stub(:first).with(:conditions => ["id > ?", employee.id], :order => "id ASC").and_return(nil) }

      context 'found first employee order by id ASC' do
        before { employee_department.employees.stub(:first).with(:order => "id ASC").and_return(employee1) }
        it 'returns next_employee' do
          employee.next_employee.should == employee1
        end
      end
    end
  end

  describe '#previous_employee' do
    let(:employee1) { FactoryGirl.build(:employee) }
    let(:employee_department) { FactoryGirl.build(:employee_department, :employees => [employee1]) }
    let(:employee) { FactoryGirl.build(:employee, :employee_department => employee_department) }

    context 'found employee with id < employee.id' do
      before { employee_department.employees.stub(:first).with(:conditions => ["id < ?", employee.id], :order => "id DESC").and_return(employee1) }

      it 'returns previous_employee' do
        employee.previous_employee.should == employee1
      end
    end

    context 'not found employee with id > employee.id' do
      before { employee_department.employees.stub(:first).with(:conditions => ["id < ?", employee.id], :order => "id DESC").and_return(nil) }

      context 'found first employee order by id DESC' do
        before { employee_department.employees.stub(:first).with(:order => "id DESC").and_return(employee1) }

        it 'returns previous_employee' do
          employee.previous_employee.should == employee1
        end
      end
    end
  end

  describe '#full_name' do
    let(:employee) { FactoryGirl.build(:employee, :first_name => 'FN', :middle_name => 'MN', :last_name => 'LN') }

    it 'returns full name' do
      employee.full_name.should == 'FN MN LN'
    end
  end

  describe '#payslip_approved?' do
    let(:employee) { FactoryGirl.build(:employee) }

    context 'found all MonthlyPayslip with salary_date, employee_id, is_approved = true' do
      let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip) }
      before { MonthlyPayslip.stub(:find_all_by_salary_date_and_employee_id_and_is_approved).with(Date.current, employee.id, true).and_return([monthly_payslip]) }

      it 'returns true' do
        employee.should be_payslip_approved(Date.current)
      end
    end

    context 'not found all MonthlyPayslip with salary_date, employee_id, is_approved = true' do
      before { MonthlyPayslip.stub(:find_all_by_salary_date_and_employee_id_and_is_approved).with(Date.current, employee.id, true).and_return([]) }

      it 'returns false' do
        employee.should_not be_payslip_approved(Date.current)
      end
    end
  end

  describe '#payslip_rejected?' do
    let(:employee) { FactoryGirl.build(:employee) }

    context 'found all MonthlyPayslip with salary_date, employee_id, is_rejected = true' do
      let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip) }
      before { MonthlyPayslip.stub(:find_all_by_salary_date_and_employee_id_and_is_rejected).with(Date.current, employee.id, true).and_return([monthly_payslip]) }

      it 'returns true' do
        employee.should be_payslip_rejected(Date.current)
      end
    end

    context 'not found all MonthlyPayslip with salary_date, employee_id, is_rejected = true' do
      before { MonthlyPayslip.stub(:find_all_by_salary_date_and_employee_id_and_is_rejected).with(Date.current, employee.id, true).and_return([]) }

      it 'returns false' do
        employee.should_not be_payslip_rejected(Date.current)
      end
    end
  end

  describe '#self.total_employees_salary' do
    let(:employee) { FactoryGirl.build(:employee) }

    context 'found all_salaries' do
      let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip) }
      before do
        employee.stub(:all_salaries).and_return([monthly_payslip])
        employee.stub(:employee_salary).and_return(35)
      end

      it 'returns salary' do
        Employee.total_employees_salary([employee], Date.current - 5.days, Date.current).should == 35
      end
    end
  end

  describe '#employee_salary' do
    let(:salary_date){ Date.current }
    let(:employee) { FactoryGirl.build(:employee) }

    context 'found all MonthlyPayslip with conditions' do
      let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip, :amount => 17) }
      before { MonthlyPayslip.stub(:find).with(:all, :order => 'salary_date desc', :conditions => ["employee_id = ? AND salary_date = ? AND is_approved = ?", employee.id, salary_date, true]).and_return([monthly_payslip]) }

      context 'found IndividualPayslipCategory with conditions' do
        let(:individual_payslip_category) { FactoryGirl.build(:individual_payslip_category, :amount => 15) }
        before { IndividualPayslipCategory.stub(:find).with(:all, :order => 'salary_date desc', :conditions => ["employee_id = ? AND salary_date >= ?", employee.id, salary_date]).and_return([individual_payslip_category]) }

        context 'individual_payslip_category.is_deduction is true' do
          before { individual_payslip_category.is_deduction = true }

          context 'found PayrollCategory' do
            let(:payroll_category) { FactoryGirl.build(:payroll_category) }
            before { PayrollCategory.stub(:find).and_return(payroll_category) }

            context 'payroll_category.is_deduction is true' do
              before { payroll_category.is_deduction = true }

              it 'returns net amount' do
                employee.employee_salary(salary_date).should == -32
              end
            end

            context 'payroll_category.is_deduction is false' do
              before { payroll_category.is_deduction = false }

              it 'returns net amount' do
                employee.employee_salary(salary_date).should == 2
              end
            end
          end
        end

        context 'individual_payslip_category.is_deduction is false' do
          before { individual_payslip_category.is_deduction = false }

          context 'found PayrollCategory' do
            let(:payroll_category) { FactoryGirl.build(:payroll_category) }
            before { PayrollCategory.stub(:find).and_return(payroll_category) }

            context 'payroll_category.is_deduction is true' do
              before { payroll_category.is_deduction = true }

              it 'returns net amount' do
                employee.employee_salary(salary_date).should == -2
              end
            end

            context 'payroll_category.is_deduction is false' do
              before { payroll_category.is_deduction = false }

              it 'returns net amount' do
                employee.employee_salary(salary_date).should == 32
              end
            end
          end
        end
      end
    end
  end


  describe '#salary' do
    let(:employee) { FactoryGirl.build(:employee) }

    context 'found MonthlyPayslip with employee_id' do
      let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip, :salary_date => Date.current) }
      before { MonthlyPayslip.stub(:find_by_employee_id).and_return(monthly_payslip) }

      it 'returns salary_date' do
        employee.salary(Date.current - 5.days, Date.current + 2.days).should == monthly_payslip.salary_date
      end
    end
  end

  describe '#archive_employee' do
    let(:status) { 'sample status' }
    let(:employee) { FactoryGirl.build(:employee, :id => 7) }

    it 'does update status_description' do
      employee.archive_employee(status)
      employee.status_description.should == status
    end

    context 'archived_employee.save is true' do
      let(:admin_user) { FactoryGirl.build(:admin_user, :is_deleted => false) }
      let(:employee_salary_structure) { FactoryGirl.build(:employee_salary_structure) }
      let(:employee_bank_detail) { FactoryGirl.build(:employee_bank_detail) }
      let(:employee_additional_detail) { FactoryGirl.build(:employee_additional_detail) }

      before do
        ArchivedEmployee.any_instance.expects(:valid?).returns(true)
        employee.user = admin_user
        employee.employee_salary_structures = [employee_salary_structure]
        employee.employee_bank_details = [employee_bank_detail]
        employee.stub(:employee_additional_details).and_return([employee_additional_detail])
      end

      it 'call method archive_employee_salary_structure' do
        employee_salary_structure.should_receive(:archive_employee_salary_structure)
        employee.archive_employee(status)
      end

      it 'call method archive_employee_bank_detail' do
        employee_bank_detail.should_receive(:archive_employee_bank_detail)
        employee.archive_employee(status)
      end

      it 'call method archive_employee_bank_detail' do
        employee_additional_detail.should_receive(:archive_employee_additional_detail)
        employee.archive_employee(status)
      end

      it 'does update employee.user.is_deleted to true' do
        employee.archive_employee(status)
        employee.user.should be_is_deleted
      end

      it 'destroy employee' do
        employee.archive_employee(status)
        employee.should be_destroyed
      end

      it 'create ArchivedEmployee' do
        employee.archive_employee(status)
        ArchivedEmployee.all.count.should == 1
      end

      it 'create ArchivedEmployee with former_id = employee.id' do
        employee.archive_employee(status)
        ArchivedEmployee.first.former_id.should == '7'
      end
    end
  end


  describe '#all_salaries' do
    let(:start_date) { Date.current - 5.days }
    let(:end_date) { Date.current + 2.days }
    let(:employee) { FactoryGirl.build(:employee) }

    context 'found MonthlyPayslip with employee_id' do
      let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip) }
      before { MonthlyPayslip.stub(:find_all_by_employee_id).with(employee.id, :select =>"distinct salary_date", :order => 'salary_date desc', :conditions => ["salary_date >= ? and salary_date <= ? and is_approved = ?", start_date.to_date, end_date.to_date, true]).and_return([monthly_payslip]) }

      it 'returns all MonthlyPayslip' do
        employee.all_salaries(start_date, end_date).should == [monthly_payslip]
      end
    end
  end

  describe '#self.calculate_salary' do
    let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip, :amount => 17) }
    let(:individual_payslip_category) { FactoryGirl.build(:individual_payslip_category, :amount => 15) }
    let(:employee) { FactoryGirl.build(:employee) }

    context 'individual_payslip_category.is_deduction is true' do
      before { individual_payslip_category.is_deduction = true }

      context 'monthly_payslip.payroll_category is present' do
        let(:payroll_category) { FactoryGirl.build(:payroll_category) }
        before { monthly_payslip.payroll_category = payroll_category }

        context 'payroll_category.is_deduction is true' do
          before { payroll_category.is_deduction = true }

          it 'returns hash' do
            hash = {:net_amount => -32.0, :net_deductionable_amount => 32.0, :net_non_deductionable_amount => 0}
            Employee.calculate_salary([monthly_payslip], [individual_payslip_category]).should == hash
          end
        end

        context 'payroll_category.is_deduction is false' do
          before { payroll_category.is_deduction = false }

          it 'returns hash' do
            hash = {:net_amount => 2.0, :net_deductionable_amount => 15.0, :net_non_deductionable_amount => 17}
            Employee.calculate_salary([monthly_payslip], [individual_payslip_category]).should == hash
          end
        end
      end

      context 'monthly_payslip.payroll_category is nil' do
        before { monthly_payslip.payroll_category = nil }

        it 'returns hash' do
          hash = {:net_amount => -15.0, :net_deductionable_amount => 15.0, :net_non_deductionable_amount => 0}
          Employee.calculate_salary([monthly_payslip], [individual_payslip_category]).should == hash
        end
      end
    end

    context 'individual_payslip_category.is_deduction is false' do
      before { individual_payslip_category.is_deduction = false }

      context 'monthly_payslip.payroll_category is present' do
        let(:payroll_category) { FactoryGirl.build(:payroll_category) }
        before { monthly_payslip.payroll_category = payroll_category }

        context 'payroll_category.is_deduction is true' do
          before { payroll_category.is_deduction = true }

          it 'returns hash' do
            hash = {:net_amount => -2.0, :net_deductionable_amount => 17.0, :net_non_deductionable_amount => 15}
            Employee.calculate_salary([monthly_payslip], [individual_payslip_category]).should == hash
          end
        end

        context 'payroll_category.is_deduction is false' do
          before { payroll_category.is_deduction = false }

          it 'returns hash' do
            hash = {:net_amount => 32.0, :net_deductionable_amount => 0.0, :net_non_deductionable_amount => 32}
            Employee.calculate_salary([monthly_payslip], [individual_payslip_category]).should == hash
          end
        end
      end

      context 'monthly_payslip.payroll_category is nil' do
        before { monthly_payslip.payroll_category = nil }

        it 'returns hash' do
          hash = {:net_amount => 15.0, :net_deductionable_amount => 0, :net_non_deductionable_amount => 15}
          Employee.calculate_salary([monthly_payslip], [individual_payslip_category]).should == hash
        end
      end
    end
  end

  describe '#self.find_in_active_or_archived' do
    context 'found Employee with id' do
      let(:employee) { FactoryGirl.build(:employee) }
      before { Employee.stub(:find_by_id).and_return(employee) }

      it 'returns employee' do
        Employee.find_in_active_or_archived(5).should == employee
      end
    end

    context 'not found Employee with id' do
      before { Employee.stub(:find_by_id).and_return(nil) }

      context 'found ArchivedEmployee with id' do
        let(:archived_employee) { FactoryGirl.build(:archived_employee) }
        before { ArchivedEmployee.stub(:find_by_id).and_return(archived_employee) }

        it 'returns archived_employee' do
          Employee.find_in_active_or_archived(5).should == archived_employee
        end
      end
    end
  end

  describe '#has_dependency' do
    let(:employee) { FactoryGirl.build(:employee) }

    context 'all conditions are nil' do
      before do
        employee.stub(:monthly_payslips).and_return(nil)
        employee.stub(:employee_salary_structures).and_return(nil)
        employee.stub(:employees_subjects).and_return(nil)
        employee.stub(:apply_leaves).and_return(nil)
        employee.stub(:finance_transactions).and_return(nil)
        employee.stub(:timetable_entries).and_return(nil)
        employee.stub(:employee_attendances).and_return(nil)
        FedenaPlugin.stub(:check_dependency).and_return(nil)
      end

      it 'returns false' do
        employee.has_dependency.should be_false
      end

      context 'one of which is true' do
        context 'monthly_payslips is true' do
          before { employee.stub(:monthly_payslips).and_return(true) }

          it 'returns true' do
            employee.has_dependency.should be_true
          end
        end

        context 'employee_salary_structures is true' do
          before { employee.stub(:employee_salary_structures).and_return(true) }

          it 'returns true' do
            employee.has_dependency.should be_true
          end
        end

        context 'employees_subjects is true' do
          before { employee.stub(:employees_subjects).and_return(true) }

          it 'returns true' do
            employee.has_dependency.should be_true
          end
        end

        context 'apply_leaves is true' do
          before { employee.stub(:apply_leaves).and_return(true) }

          it 'returns true' do
            employee.has_dependency.should be_true
          end
        end

        context 'finance_transactions is true' do
          before { employee.stub(:finance_transactions).and_return(true) }

          it 'returns true' do
            employee.has_dependency.should be_true
          end
        end

        context 'timetable_entries is true' do
          before { employee.stub(:timetable_entries).and_return(true) }

          it 'returns true' do
            employee.has_dependency.should be_true
          end
        end

        context 'employee_attendances is true' do
          before { employee.stub(:employee_attendances).and_return(true) }

          it 'returns true' do
            employee.has_dependency.should be_true
          end
        end

        context 'FedenaPlugin check_dependency is true' do
          before { FedenaPlugin.stub(:check_dependency).and_return(true) }

          it 'returns true' do
            employee.has_dependency.should be_true
          end
        end
      end
    end
  end

  describe '#former_dependency' do
    let(:employee) { FactoryGirl.build(:employee) }
    before { FedenaPlugin.stub(:check_dependency).and_return([]) }

    it 'returns FedenaPlugin check_dependency' do
      employee.former_dependency.should == []
    end
  end

  describe '.search_employees' do
    let(:params) { { query: query }.merge(additional_params) }
    let(:additional_params) { {} }
    let(:query) { '' }
    subject { Employee.search_employees(params) }

    Employee::EMPLOYEE_QUERY_VARIABLES.each do |key|
      context "when #{key} is present" do
        let(:var_id) { 1 }
        let!(:data) { { key => create(:employee, key => var_id) } }
        let(:additional_params) { { key => var_id } }

        it { should include(data[key]) }
      end
    end

    context 'when length query is equal or greater than 3' do
      let(:employee_by_name) { create(:employee, first_name: first_name) }
      let(:first_name) { 'first_name' }
      let(:query) { first_name }
      it { should include(employee_by_name) }
    end

    context 'when length query is not equal or greater than 3' do
      let(:employee_by_number) { create(:employee, employee_number: employee_number.to_i) }
      let(:employee_number) { '1' }
      let(:query) { employee_number }
      it { should include(employee_by_number) }
    end
  end
end
