require 'spec_helper'

describe MonthlyPayslip do

  it { should validate_presence_of(:salary_date) }

  it { should belong_to(:payroll_category) }
  it { should belong_to(:employee) }
  it { should belong_to(:approver).class_name('User') }
  #it { should belong_to(:country).class_name('User') }

  describe '#approve' do
    let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip, :is_approved => false) }

    context 'approve with arguments' do
      before { monthly_payslip.approve(5, 10) }

      it 'does update is_approved to true' do
        monthly_payslip.should be_is_approved
      end

      it 'does update approver_id' do
        monthly_payslip.approver_id.should == 5
      end

      it 'does update remark' do
        monthly_payslip.remark.should == 10
      end
    end
  end

  describe '#reject' do
    let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip, :is_rejected => false) }

    context 'reject with arguments' do
      before { monthly_payslip.reject(5, 'sample reason') }

      it 'does update is_rejected to true' do
        monthly_payslip.should be_is_rejected
      end

      it 'does update rejector_id' do
        monthly_payslip.rejector_id.should == 5
      end

      it 'does update reason' do
        monthly_payslip.reason.should == 'sample reason'
      end
    end
  end

  describe '#self.find_and_filter_by_department' do
    let(:salary_date) { Date.current }

    context 'dept_id != All' do
      let(:dept_id) { 'no all' }

      context 'found all Employee with conditions' do
        let(:employee) { FactoryGirl.create(:employee) }
        before { Employee.stub(:find).with(:all, :select => "id", :conditions => ["employee_department_id = ?", dept_id]).and_return([employee]) }

        context 'found all ArchivedEmployee with conditions' do
          let(:archived_employee) { ArchivedEmployee.new(:former_id => 12) }
          before { ArchivedEmployee.stub(:find).with(:all, :select => "former_id", :conditions => ["employee_department_id = ?", dept_id]).and_return([archived_employee]) }

          context 'payslips is present' do
            context 'found MonthlyPayslip with salary_date' do
              let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip, :employee_id => 5) }
              before { MonthlyPayslip.stub(:find_all_by_salary_date).with(salary_date.to_date, :conditions => ["employee_id IN (?)", [employee.id, archived_employee.former_id]], :order => "payroll_category_id ASC", :include => [:payroll_category]).and_return([monthly_payslip]) }

              context 'individual_payslip_category is present' do
                context 'found all IndividualPayslipCategory with salary_date' do
                  let(:individual_payslip_cat) { IndividualPayslipCategory.new(:employee_id => 6) }
                  before { IndividualPayslipCategory.stub(:find_all_by_salary_date).with(salary_date.to_date, :conditions => ["employee_id IN (?)", [employee.id, archived_employee.former_id]], :order => "id ASC").and_return([individual_payslip_cat]) }

                  it 'returns hash' do
                    hash = {:monthly_payslips => { 5 => [monthly_payslip]}, :individual_payslip_category => { 6 => [individual_payslip_cat]} }
                    MonthlyPayslip.find_and_filter_by_department(salary_date, dept_id).should == hash
                  end
                end
              end
            end
          end
        end
      end
    end

    context 'dept_id = All' do
      let(:dept_id) { 'All' }

      context 'payslips is present' do
        context 'found MonthlyPayslip with salary_date' do
          let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip, :employee_id => 5) }
          before { MonthlyPayslip.stub(:find_all_by_salary_date).with(salary_date.to_date, :order => "payroll_category_id ASC", :include => [:payroll_category]).and_return([monthly_payslip]) }

          context 'individual_payslip_category is present' do
            context 'found all IndividualPayslipCategory with salary_date' do
              let(:individual_payslip_cat) { IndividualPayslipCategory.new(:employee_id => 6) }
              before { IndividualPayslipCategory.stub(:find_all_by_salary_date).with(salary_date.to_date, :order => "id ASC").and_return([individual_payslip_cat]) }

              it 'returns hash' do
                hash = {:monthly_payslips => { 5 => [monthly_payslip]}, :individual_payslip_category => { 6 => [individual_payslip_cat] }}
                MonthlyPayslip.find_and_filter_by_department(salary_date, dept_id).should == hash
              end
            end
          end
        end
      end
    end
  end

  describe '#active_or_archived_employee' do
    let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip, :employee_id => 5) }

    context 'employee is present' do
      let(:employee) { FactoryGirl.build(:employee) }
      before { Employee.stub(:find).with(:first, :conditions => ["id = ?", monthly_payslip.employee_id]).and_return(employee) }

      it 'returns employee' do
        monthly_payslip.active_or_archived_employee.should == employee
      end
    end

    context 'employee is nil' do
      before { Employee.stub(:find).with(:first, :conditions => ["id = ?", monthly_payslip.employee_id]).and_return(nil) }

      context 'found ArchivedEmployee with conditions' do
        let(:archived_employee) { ArchivedEmployee.new }
        before { ArchivedEmployee.stub(:find).with(:first, :conditions => ["former_id = ?", monthly_payslip.employee_id]).and_return(archived_employee) }

        it 'returns archived_employee' do
          monthly_payslip.active_or_archived_employee.should == archived_employee
        end
      end
    end
  end

  describe '#status_as_text' do
    let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip) }

    context 'is_approved is true' do
      before { monthly_payslip.is_approved = true }

      it 'returns Approved' do
        monthly_payslip.status_as_text.should == I18n.t('approved')
      end
    end

    context 'is_rejected is true' do
      before { monthly_payslip.is_rejected = true }

      it 'returns Rejected' do
        monthly_payslip.status_as_text.should == I18n.t('rejected')
      end
    end

    context 'is_approved and is_rejected are false' do
      before do
        monthly_payslip.is_approved = false
        monthly_payslip.is_rejected = false
      end

      it 'returns Pending' do
        monthly_payslip.status_as_text.should == I18n.t('pending')
      end
    end
  end

  describe '#self.total_employees_salary' do
    let(:start_date) { Date.current }
    let(:end_date) { Date.current + 10.days }

    context 'dept_id is present' do
      let(:dept_id) { 'All' }

      context 'found all Employee with conditions' do
        let(:employee) { FactoryGirl.build(:employee, :id => 5) }
        before { Employee.stub(:find).with(:all, :select => "id", :conditions => ["employee_department_id = ?", dept_id]).and_return([employee]) }

        context 'found all ArchivedEmployee with conditions' do
          let(:archived_employee) { ArchivedEmployee.new(:former_id => 6) }
          before { ArchivedEmployee.stub(:find).with(:all, :select => "former_id", :conditions => ["employee_department_id = ?", dept_id]).and_return([archived_employee]) }

          context 'total_monthly_payslips is any' do
            context 'found MonthlyPayslip with conditions' do
              let(:payroll_category) { PayrollCategory.new }
              let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip, :amount => 25, :payroll_category => payroll_category) }
              before { MonthlyPayslip.stub(:find).with(:all, :select => "employee_id, amount, payroll_category_id, salary_date", :order => 'salary_date desc', :conditions => ["salary_date >= ? and salary_date <= ? and is_approved = 1 and employee_id IN (?)", start_date.to_date, end_date.to_date, [employee.id, archived_employee.former_id]], :include => [:payroll_category]).and_return([monthly_payslip]) }

              context 'employee_ids is any' do
                before { monthly_payslip.employee_id = 8 }

                context 'found IndividualPayslipCategory with conditions' do
                  let(:individual_payslip_cat) { IndividualPayslipCategory.new(:amount => 14) }
                  before { IndividualPayslipCategory.stub(:find).with(:all, :conditions => ["salary_date >= ? and salary_date <= ? AND employee_id IN (?)", start_date.to_date, end_date.to_date, "8"], :order => "id ASC").and_return([individual_payslip_cat]) }

                  context 'payroll_category.is_deduction is false' do
                    before { monthly_payslip.payroll_category.is_deduction = false }

                    context 'individual_payslip_cat.is_deduction is false' do
                      before { individual_payslip_cat.is_deduction = false }

                      it 'return hash' do
                        hash = {:total_salary => 39.0, :monthly_payslips => [monthly_payslip], :individual_categories => [individual_payslip_cat]}
                        MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
                      end
                    end

                    context 'individual_payslip_cat.is_deduction is true' do
                      before { individual_payslip_cat.is_deduction = true }

                      it 'return hash' do
                        hash = {:total_salary => 11.0, :monthly_payslips => [monthly_payslip], :individual_categories => [individual_payslip_cat]}
                        MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
                      end
                    end
                  end

                  context 'payroll_category.is_deduction is true' do
                    before { monthly_payslip.payroll_category.is_deduction = true }

                    context 'individual_payslip_cat.is_deduction is false' do
                      before { individual_payslip_cat.is_deduction = false }

                      it 'return hash' do
                        hash = {:total_salary => -11.0, :monthly_payslips => [monthly_payslip], :individual_categories => [individual_payslip_cat]}
                        MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
                      end
                    end

                    context 'individual_payslip_cat.is_deduction is true' do
                      before { individual_payslip_cat.is_deduction = true }

                      it 'return hash' do
                        hash = {:total_salary => -39.0, :monthly_payslips => [monthly_payslip], :individual_categories => [individual_payslip_cat]}
                        MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
                      end
                    end
                  end

                end
              end

              context 'employee_ids is empty or not found individual_payslip_cat' do
                before { monthly_payslip.employee_id = nil }

                context 'payroll_category.is_deduction is false' do
                  before { monthly_payslip.payroll_category.is_deduction = false }

                  it 'return hash' do
                    hash = {:total_salary => 25.0, :monthly_payslips => [monthly_payslip], :individual_categories => []}
                    MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
                  end
                end

                context 'payroll_category.is_deduction is true' do
                  before { monthly_payslip.payroll_category.is_deduction = true }

                  it 'return hash' do
                    hash = {:total_salary => -25.0, :monthly_payslips => [monthly_payslip], :individual_categories => []}
                    MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
                  end
                end
              end
            end
          end

          context 'total_monthly_payslips is empty' do
            context 'not found MonthlyPayslip with conditions' do
              before { MonthlyPayslip.stub(:find).with(:all, :select => "employee_id, amount, payroll_category_id, salary_date", :order => 'salary_date desc', :conditions => ["salary_date >= ? and salary_date <= ? and is_approved = 1 and employee_id IN (?)", start_date.to_date, end_date.to_date, [employee.id, archived_employee.former_id]], :include => [:payroll_category]).and_return([]) }

              it 'return hash' do
                hash = {:total_salary => 0, :monthly_payslips => [], :individual_categories => []}
                MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
              end
            end
          end
        end
      end
    end

    context 'dept_id is blank' do
      let(:dept_id) { '' }

      context 'total_monthly_payslips is any' do
        context 'found MonthlyPayslip with conditions' do
          let(:payroll_category) { PayrollCategory.new }
          let(:monthly_payslip) { FactoryGirl.build(:monthly_payslip, :amount => 25, :payroll_category => payroll_category) }
          before { MonthlyPayslip.stub(:find).with(:all, :select => "employee_id, amount, payroll_category_id, salary_date", :order => 'salary_date desc', :conditions => ["salary_date >= ? and salary_date <= ? and is_approved = 1", start_date.to_date, end_date.to_date], :include => [:payroll_category]).and_return([monthly_payslip]) }

          context 'employee_ids is any' do
            before { monthly_payslip.employee_id = 8 }

            context 'found IndividualPayslipCategory with conditions' do
              let(:individual_payslip_cat) { IndividualPayslipCategory.new(:amount => 14) }
              before { IndividualPayslipCategory.stub(:find).with(:all, :conditions => ["salary_date >= ? and salary_date <= ? AND employee_id IN (?)", start_date.to_date, end_date.to_date, "8"], :order => "id ASC").and_return([individual_payslip_cat]) }

              context 'payroll_category.is_deduction is false' do
                before { monthly_payslip.payroll_category.is_deduction = false }

                context 'individual_payslip_cat.is_deduction is false' do
                  before { individual_payslip_cat.is_deduction = false }

                  it 'return hash' do
                    hash = {:total_salary => 39.0, :monthly_payslips => [monthly_payslip], :individual_categories => [individual_payslip_cat]}
                    MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
                  end
                end

                context 'individual_payslip_cat.is_deduction is true' do
                  before { individual_payslip_cat.is_deduction = true }

                  it 'return hash' do
                    hash = {:total_salary => 11.0, :monthly_payslips => [monthly_payslip], :individual_categories => [individual_payslip_cat]}
                    MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
                  end
                end
              end

              context 'payroll_category.is_deduction is true' do
                before { monthly_payslip.payroll_category.is_deduction = true }

                context 'individual_payslip_cat.is_deduction is false' do
                  before { individual_payslip_cat.is_deduction = false }

                  it 'return hash' do
                    hash = {:total_salary => -11.0, :monthly_payslips => [monthly_payslip], :individual_categories => [individual_payslip_cat]}
                    MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
                  end
                end

                context 'individual_payslip_cat.is_deduction is true' do
                  before { individual_payslip_cat.is_deduction = true }

                  it 'return hash' do
                    hash = {:total_salary => -39.0, :monthly_payslips => [monthly_payslip], :individual_categories => [individual_payslip_cat]}
                    MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
                  end
                end
              end

            end
          end

          context 'employee_ids is empty or not found individual_payslip_cat' do
            before { monthly_payslip.employee_id = nil }

            context 'payroll_category.is_deduction is false' do
              before { monthly_payslip.payroll_category.is_deduction = false }

              it 'return hash' do
                hash = {:total_salary => 25.0, :monthly_payslips => [monthly_payslip], :individual_categories => []}
                MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
              end
            end

            context 'payroll_category.is_deduction is true' do
              before { monthly_payslip.payroll_category.is_deduction = true }

              it 'return hash' do
                hash = {:total_salary => -25.0, :monthly_payslips => [monthly_payslip], :individual_categories => []}
                MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
              end
            end
          end
        end
      end

      context 'total_monthly_payslips is empty' do
        context 'not found MonthlyPayslip with conditions' do
          before { MonthlyPayslip.stub(:find).with(:all, :select => "employee_id, amount, payroll_category_id, salary_date", :order => 'salary_date desc', :conditions => ["salary_date >= ? and salary_date <= ? and is_approved = 1", start_date.to_date, end_date.to_date], :include => [:payroll_category]).and_return([]) }

          it 'return hash' do
            hash = {:total_salary => 0, :monthly_payslips => [], :individual_categories => []}
            MonthlyPayslip.total_employees_salary(start_date, end_date, dept_id).should == hash
          end
        end
      end
    end
  end
end