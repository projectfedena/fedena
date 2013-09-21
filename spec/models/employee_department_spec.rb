require 'spec_helper'

describe EmployeeDepartment do

  it { should validate_presence_of(:name) }
  it { should have_many(:employees) }
  it { should have_many(:employee_department_events) }
  it { should have_many(:events).through(:employee_department_events) }

  context 'a exists record' do
    let!(:department) { Factory.create(:employee_department) }

    it { should validate_uniqueness_of(:name) }
    it { should validate_uniqueness_of(:code) }
  end

  describe ".active" do
    let!(:department1) { Factory.create(:employee_department, :status => true) }
    let!(:department2) { Factory.create(:employee_department, :status => false) }

    it "returns active EmployeeDepartment" do
      EmployeeDepartment.active.should == [department1]
    end
  end

  describe "#department_total_salary" do
    let!(:employee) { Factory.create(:employee) }
    let!(:department) { Factory.create(:employee_department, :employees => [employee]) }
    let!(:monthly_payslip) { MonthlyPayslip.new(:salary_date => Date.current) }
    before do
      Employee.any_instance.expects(:all_salaries).returns([monthly_payslip])
      Employee.any_instance.expects(:employee_salary).returns(5.5)
    end

    it "returns active EmployeeDepartment" do
      department.department_total_salary(1,2).should == 5.5
    end
  end
end
