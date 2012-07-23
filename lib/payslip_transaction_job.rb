class PayslipTransactionJob

  def initialize(*args)
    opts = args.extract_options!

    @employee_ids = opts[:employee_id].split(',')
    @salary_date = Date.parse(opts[:salary_date])
  end

  def perform
    @employee_ids.each do |employee_id|
      employee = Employee.find_by_id employee_id
      monthly_payslips = MonthlyPayslip.find(:all,:conditions=>["employee_id=? AND salary_date = ?", employee.id, @salary_date],:include=>:payroll_category)
      individual_payslips =  IndividualPayslipCategory.find(:all,:conditions=>["employee_id=? AND salary_date = ?", employee.id, @salary_date])
      salary  = Employee.calculate_salary(monthly_payslips, individual_payslips)

      FinanceTransaction.create(
        :title => "Monthly Salary",
        :description => "Salary of #{employee.employee_number} for the month #{I18n.l(@salary_date, :format=>:month_year)}",
        :amount => salary[:net_amount],
        :category_id => FinanceTransactionCategory.find_by_name('Salary').id,
        :transaction_date => Date.today,
        :payee => employee
      )
    end
  end

end
