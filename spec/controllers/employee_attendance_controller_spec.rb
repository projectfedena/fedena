require 'spec_helper'

describe EmployeeAttendanceController do
  let!(:configuration) { create(:configuration, config_value: 'HR') }

  before do
    @user = FactoryGirl.create(:admin_user)
    sign_in(@user)
  end

  describe 'GET add_leave_types' do
    let!(:leave_types) { create_list(:employee_leave_type, 2, status: true) }
    let!(:inactive_leave_types) { create_list(:employee_leave_type, 2, status: false) }
    let!(:employee) { create_list(:employee, 2) }
    let(:params) { { leave_type: { status: status } } }
    let(:status) { true }

    it 'assigns all necessary information' do
      get :add_leave_types, params
      assigns[:leave_types].should == leave_types
      assigns[:inactive_leave_types].should == inactive_leave_types
      assigns[:leave_type].should be_a(EmployeeLeaveType)
      assigns[:leave_type].should be_new_record
      assigns[:leave_type].status.should == status
      assigns[:employee] = [employee]
    end
  end

  describe 'POST add_leave_types' do
    let(:employee_number) { 2 }
    let!(:employee) { create_list(:employee, employee_number) }

    context 'when params is valid' do
      let(:params) { { leave_type: attributes_for(:employee_leave_type) } }

      it 'creates new leave type' do
        expect {
          post :add_leave_types, params
        }.to change { EmployeeLeaveType.count }.by(1)
      end

      it 'creates new employee leave' do
        expect {
          post :add_leave_types, params
        }.to change { EmployeeLeave.count }.by(employee_number)
      end

      it 'redirects' do
        post :add_leave_types, params
        flash[:notice].should be_present
        response.should redirect_to(action: 'add_leave_types')
      end
    end

    context 'when params is invalid' do
      let(:params) { { leave_type: {} } }

      it 'does not create new leave type' do
        expect {
          post :add_leave_types, params
        }.to_not change { EmployeeLeaveType.count }
      end

      it 'does not create new employee leave' do
        expect {
          post :add_leave_types, params
        }.to_not change { EmployeeLeave.count }
      end

      it 'does not redirect' do
        post :add_leave_types, params
        flash[:notice].should be_blank
        response.should be_success
      end
    end
  end

  describe 'GET edit_leave_types' do
    let(:employee_leave_type) { create(:employee_leave_type) }

    it 'assigns leave type' do
      get :edit_leave_types, id: employee_leave_type.id
      assigns[:leave_type].should == employee_leave_type
    end
  end

  describe 'POST edit_leave_types' do
    before { post :edit_leave_types, params }
    let(:employee_leave_type) { create(:employee_leave_type) }
    let(:params) do
      {
        leave_type: leave_type_attr,
        id: employee_leave_type.id
      }
    end

    context 'when params is valid' do
      let(:name) { 'name' }
      let(:leave_type_attr) { { name: name } }

      it 'updates leave type' do
        employee_leave_type.reload.name.should == name
      end

      it 'redirects to add leave types page' do
        flash[:notice].should be_present
        response.should redirect_to(action: 'add_leave_types')
      end
    end

    context 'when params is invalid' do
      let(:leave_type_attr) { { name: nil } }

      it 'does not redirect' do
        flash[:notice].should be_blank
        response.should be_success
      end
    end
  end

  describe 'DELETE delete_leave_types' do
    let(:employee_leave_type) { create(:employee_leave_type) }

    it 'redirects to add leave types page' do
      delete :delete_leave_types, id: employee_leave_type.id
      response.should redirect_to(action: 'add_leave_types')
    end

    context 'when there is attendance' do
      let!(:attendance) do
        create(:employee_attendance,
               employee_leave_type_id: employee_leave_type.id)
      end

      it 'does not delete employee leave' do
        expect {
          delete :delete_leave_types, id: employee_leave_type.id
        }.to_not change{ EmployeeLeave.count }
      end

      it 'does not delete employee leave type' do
        expect {
          delete :delete_leave_types, id: employee_leave_type.id
        }.to_not change{ EmployeeLeaveType.count }
        employee_leave_type.reload.should be_present
      end
    end

    context 'when there is no attendance' do
      let!(:employee_leaves) do
        create_list(:employee_leave, employee_number,
                    employee_leave_type_id: employee_leave_type.id)
      end
      let(:employee_number) { 2 }

      it 'does not delete employee leave' do
        expect {
          delete :delete_leave_types, id: employee_leave_type.id
        }.to change{ EmployeeLeave.count }.by(-employee_number)
      end

      it 'does not delete employee leave type' do
        expect {
          delete :delete_leave_types, id: employee_leave_type.id
        }.to change{ EmployeeLeaveType.count }.by(-1)
        EmployeeLeaveType.find_by_id(employee_leave_type.id).should be_nil
      end
    end
  end

  describe 'GET leave_reset_settings' do
    let!(:auto_reset) { create(:configuration, config_key: 'AutomaticLeaveReset') }
    let!(:reset_period) { create(:configuration, config_key: 'LeaveResetPeriod') }
    let!(:last_reset) { create(:configuration, config_key: 'LastAutoLeaveReset') }
    let!(:fin_start_date) { create(:configuration, config_key: 'FinancialYearStartDate') }

    it 'assigns information' do
      get :leave_reset_settings
      assigns[:auto_reset].should == auto_reset
      assigns[:reset_period].should == reset_period
      assigns[:last_reset].should == last_reset
      assigns[:fin_start_date].should == fin_start_date
    end
  end

  describe 'POST leave_reset_settings' do
    let!(:auto_reset) { create(:configuration, config_key: 'AutomaticLeaveReset') }
    let!(:reset_period) { create(:configuration, config_key: 'LeaveResetPeriod') }
    let!(:last_reset) { create(:configuration, config_key: 'LastAutoLeaveReset') }
    let!(:fin_start_date) { create(:configuration, config_key: 'FinancialYearStartDate') }
    let(:automatic_leave_reset) { 'automatic_leave_reset' }
    let(:leave_reset_period) { 'leave_reset_period' }
    let(:financial_year_start_date) { 'financial_year_start_date' }
    let(:params) do
      {
        configuration: {
          automatic_leave_reset: automatic_leave_reset,
          leave_reset_period: leave_reset_period,
          financial_year_start_date: financial_year_start_date
        }
      }
    end

    it 'updates information' do
      post :leave_reset_settings, params
      auto_reset.reload.config_value.should == automatic_leave_reset
      reset_period.reload.config_value.should == leave_reset_period
      last_reset.reload.config_value.should == financial_year_start_date
    end
  end

  describe 'GET update_employee_leave_reset_all' do
    it 'resets all employee leave' do
      EmployeeLeave.expects(:reset_all)
      get :update_employee_leave_reset_all
    end

    it 'replaces main reset box by notice message' do
      get :update_employee_leave_reset_all
      response.should have_rjs(:replace_html, 'main-reset-box')
    end
  end

  describe 'GET employee_leave_reset_by_department' do
    let!(:departments) { create_list(:employee_department, 2, status: true) }
    it 'assigns departments' do
      get :employee_leave_reset_by_department
      assigns[:departments].should == departments
    end
  end

  describe 'GET list_department_leave_reset' do
    context 'always' do
      let!(:leave_types) { create_list(:employee_leave_type, 2, status: true) }
      before { get :list_department_leave_reset }

      it 'assigns leave types' do
        assigns[:leave_types].should == leave_types
      end
    end

    context 'when department id is blank' do
      let(:department_id) { nil }

      before { get :list_department_leave_reset, department_id: department_id }

      it 'does not assign employees' do
        assigns[:employees].should be_nil
      end

      it 'replaces department list by blank text' do
        response.should have_rjs(:replace_html, 'department-list')
      end
    end

    context 'when department id is not blank' do
      let(:department_id) { department.id }
      let!(:employees) { create_list(:employee, 2, employee_department_id: department.id) }
      let(:department) { create(:employee_department) }
      before { get :list_department_leave_reset, department_id: department_id }

      it 'assigns employees' do
        assigns[:employees].should == employees
      end

      it 'replaces department list by new department list' do
        response.should have_rjs(:replace_html, 'department-list')
        response.should render_template(partial: 'department_list')
      end
    end
  end

  describe 'GET update_department_leave_reset' do
    let(:employees) { create_list(:employee, 2) }
    let(:employee) { employees.last }
    let(:employee_number) { 2 }
    let!(:leave_count) { create_list(:employee_leave, employee_number, employee_id: employee.id) }

    it 'redirects' do
      EmployeeLeave.any_instance.expects(:reset).times(employee_number)
      get :update_department_leave_reset, employee_id: employees.map(&:id)
      flash[:notice].should be_present
      response.should redirect_to(action: :employee_leave_reset_by_department)
    end
  end

  describe 'GET employee_leave_reset_by_employee' do
    let!(:info) do
      {
        departments: create_list(:employee_department, 2),
        categories: create_list(:employee_category, 2),
        positions: create_list(:employee_position, 2),
        grades: create_list(:employee_grade, 2)
      }
    end

    it 'assigns information' do
      get :employee_leave_reset_by_employee
      info.each do |key, value|
        assigns[key].should == value
      end
    end
  end

  describe 'GET employee_search_ajax' do
    let(:params) { {} }
    let(:employee) { create(:employee) }

    it 'searchs employees by params' do
      Employee.expects(:search_employees).returns([employee])
      get :employee_search_ajax, params
      assigns[:employee].should == [employee]
      response.should render_template(layout: false)
    end
  end

  describe 'GET employee_view_all' do
    let!(:employee_department) { create(:employee_department) }

    it 'assigns employee_department' do
      get :employee_view_all
      assigns[:departments].should == [employee_department]
    end
  end

  describe 'GET employees_list' do
    let!(:employees) { create_list(:employee, 2, employee_department_id: employee_department_id) }
    let(:params) { { department_id: employee_department_id } }
    let(:employee_department_id) { create(:employee_department).id }

    before { get :employees_list, params }

    it 'assigns employees' do
      assigns[:employees].should == employees
    end

    it 'relace employee list by new list' do
      response.should have_rjs(:replace_html, 'employee_list')
      response.should render_template(partial: 'employee_view_all_list')
    end
  end

  describe 'GET employee_leave_details' do
    let(:employee) { create(:employee) }
    let!(:leave_count) { create_list(:employee_leave, 2, employee_id: employee.id) }

    it 'assigns information' do
      get :employee_leave_details, id: employee.id
      assigns[:employee].should == employee
      assigns[:leave_count].should == leave_count
    end
  end

  describe 'GET employee_wise_leave_reset' do
    let(:employee) { create(:employee) }
    let(:employee_number) { 2 }
    let!(:leave_count) { create_list(:employee_leave, employee_number, employee_id: employee.id) }

    before do
      EmployeeLeave.any_instance.expects(:reset).times(employee_number)
      get :employee_wise_leave_reset, id: employee.id
    end

    it 'assigns information' do
      assigns[:employee].should == employee
      assigns[:leave_count].should == leave_count
    end

    it 'replaces list by success notice' do
      response.should have_rjs(:replace_html, 'list')
      response.should render_template(partial: 'employee_reset_success')
    end
  end

  describe 'GET register' do
    let!(:departments) { create_list(:employee_department, 2, status: true) }

    it 'assigns information' do
      get :register
      assigns[:departments].should == departments.sort_by(&:name)
    end
  end

  describe 'POST register' do
    let!(:departments) { create_list(:employee_department, 2, status: true) }
    let(:params) do
      {
        employee_attendance: employee_attendance,
        date: Date.today
      }
    end

    context 'when employee attendance is present' do
      let(:employee_attendance) { {1 => 2} }

      it 'does not create new employee attendance' do
        expect {
          post :register, params
        }.to change{ EmployeeAttendance.count }.by(1)
      end

      it 'does not redirect' do
        post :register, params
        response.should redirect_to(action: 'register')
        flash[:notice].should be_present
      end
    end

    context 'when employe attendance is not present' do
      let(:employee_attendance) { nil }

      it 'does not create new employee attendance' do
        expect {
          post :register, params
        }.to_not change{ EmployeeAttendance.count }
      end

      it 'does not redirect' do
        post :register, params
        response.should be_success
        flash[:notice].should be_blank
      end
    end
  end

  describe 'GET update_attendance_form' do
    let!(:leave_types) { create_list(:employee_leave_type, 2, status: true) }
    let!(:employees) { create_list(:employee, 2, employee_department_id: department.id) }
    let(:department) { create(:employee_department) }
    let(:params) { { department_id: employee_department_id } }
    let(:employee_department_id) { nil }

    before { get :update_attendance_form, params }

    it 'assigns leave types' do
      assigns[:leave_types].should == leave_types
    end

    context 'when department_id is blank' do
      it 'replaces attendance form with blank text' do
        response.should have_rjs(:replace_html, 'attendance_form')
        response.should render_template(text: '')
      end
    end

    context 'when department id is not blank' do
      let(:employee_department_id) { department.id }

      it 'assigns employees' do
        assigns[:employees].should == employees
      end

      it 'replaces attendance form with new attendance form' do
        response.should have_rjs(:replace_html, 'attendance_form')
        response.should render_template(partial: 'attendance_form')
      end
    end
  end

  describe 'GET report' do
    let!(:departments) { create_list(:employee_department, 2, status: true) }

    it 'assigns all departments' do
      get :report
      assigns[:departments].should == departments
    end
  end

  describe 'GET update_attendance_report' do
    let!(:leave_types) { create_list(:employee_leave_type, 2, status: true) }
    let!(:employees) { create_list(:employee, 2, employee_department_id: department.id) }
    let(:department) { create(:employee_department) }
    let(:params) { { department_id: employee_department_id } }
    let(:employee_department_id) { nil }

    before { get :update_attendance_report, params }

    it 'assigns leave types' do
      assigns[:leave_types].should == leave_types
    end

    context 'when department_id is blank' do
      it 'replaces attendance form with blank text' do
        response.should have_rjs(:replace_html, 'attendance_report')
        response.should render_template(text: '')
      end
    end

    context 'when department id is not blank' do
      let(:employee_department_id) { department.id }

      it 'assigns employees' do
        assigns[:employees].should == employees
      end

      it 'replaces attendance form with new attendance form' do
        response.should have_rjs(:replace_html, 'attendance_report')
        response.should render_template(partial: 'attendance_report')
      end
    end
  end

  describe 'GET emp_attendance' do
    let(:employee) { create(:employee) }
    let!(:attendance_reports) { [create(:employee_attendance, employee_id: employee.id)] }
    let!(:leave_types) { create_list(:employee_leave_type, 2, status: true) }
    let!(:leave_count) do
      create_list(:employee_leave, 2,
                  employee_leave_type_id: leave_types.first.id,
                  employee_id: employee.id)
    end

    it 'assigns information' do
      get :emp_attendance, id: employee.id
      assigns[:employee].should == employee
      assigns[:attendance_report].should == attendance_reports
      assigns[:leave_types].should == leave_types
      assigns[:leave_count].should == leave_count
      assigns[:total_leaves].should == 0
    end
  end

  describe 'GET leave_history' do
    let(:employee) { create(:employee) }

    it 'assigns employee' do
      get :emp_attendance, id: employee.id
      assigns[:employee].should == employee
    end
  end

  describe 'GET update_leave_history' do
    let(:employee) { create(:employee) }
    let!(:leave_types) { create_list(:employee_leave_type, 2, status: true) }
    let!(:employee_attendances) do
      create_list(:employee_attendance, 2,
                  employee_leave_type_id: leave_types.first.id,
                  employee_id: employee.id,
                  attendance_date: 5.days.from_now)
    end
    let(:params) do
      {
        period: { start_date: Date.today, end_date: 10.days.from_now },
        id: employee.id
      }
    end

    before { get :update_leave_history, params }

    it 'assigns information' do
      assigns[:employee].should == employee
      assigns[:leave_types].should == leave_types
      assigns[:employee_attendances].values.should include(employee_attendances)
      assigns[:employee_attendances].keys.should include(leave_types.first.name)
    end

    it 'replaces attendance report' do
      response.should have_rjs(:replace_html, 'attendance-report')
      response.should render_template('update_leave_history')
    end
  end

  describe 'GET leaves' do
    let!(:leave_types) { create_list(:employee_leave_type, 2, status: true) }
    let!(:employee) { create(:employee) }
    let!(:reporting_employees) { create_list(:employee, 2, reporting_manager_id: employee.id) }

    before do
      employee.user = @user
      employee.save
    end

    it 'assigns information' do
      get :leaves, id: employee.id
      assigns[:leave_types].should == leave_types
      assigns[:employee].should == employee
      assigns[:reporting_employees].should == reporting_employees
      assigns[:total_leave_count].should == 0
    end
  end

  describe 'POST leaves' do
    let!(:leave_types) { create_list(:employee_leave_type, 2, status: true) }
    let!(:employee) { create(:employee, user_id: @user.id) }
    let!(:reporting_employees) { create_list(:employee, 2, reporting_manager_id: employee.id) }

    before do
      employee.user = @user
      employee.save
    end

    context 'when leave_apply data is valid' do
      let(:leave_apply) { attributes_for(:apply_leave) }

      it 'redirects to leave' do
        ApplyLeave.expects(:update)
        post :leaves, id: employee.id, leave_apply: leave_apply
        response.should redirect_to(action: 'leaves', id: employee.id)
        flash[:notice].should be_present
      end
    end

    context 'when leave_apply data is invalid' do
      let(:leave_apply) { attributes_for(:apply_leave, reason: nil) }

      it 'redirects to leave' do
        ApplyLeave.expects(:update).never
        post :leaves, id: employee.id, leave_apply: leave_apply
        response.should be_success
        flash[:notice].should be_blank
      end
    end
  end

  describe 'GET leave_application' do
    let(:applied_leave) do
      create(:apply_leave,
             employee_id: applied_employee.id,
             employee_leave_type_id: leave_type.id)
    end
    let(:applied_employee) { create(:employee, reporting_manager_id: manager) }
    let(:leave_type) { create(:employee_leave_type) }
    let(:manager) { create(:employee).id }
    let!(:leave_count) do
      create(:employee_leave,
             employee_id: applied_employee.id,
             employee_leave_type_id: leave_type.id,
             leave_taken: 4,
             leave_count: 5)
    end

    it 'assigns information' do
      get :leave_application, id: applied_leave.id
      assigns[:applied_leave] = applied_leave
      assigns[:applied_employee] = applied_employee
      assigns[:leave_type] = leave_type
      assigns[:manager] = manager
      assigns[:leave_count] = leave_count
    end
  end

  describe 'leave_app' do
    let(:applied_leave) do
      create(:apply_leave,
             employee_id: applied_employee.id,
             employee_leave_type_id: leave_type.id)
    end
    let(:employee) { create(:employee) }
    let(:applied_employee) { create(:employee, reporting_manager_id: manager) }
    let(:leave_type) { create(:employee_leave_type) }
    let(:manager) { create(:employee).id }
    let!(:leave_count) do
      create(:employee_leave,
             employee_id: applied_employee.id,
             employee_leave_type_id: leave_type.id,
             leave_taken: 4,
             leave_count: 5)
    end

    it 'assigns information' do
      get :leave_app, id: applied_leave.id, id2: employee.id
      assigns[:applied_leave] = applied_leave
      assigns[:applied_employee] = applied_employee
      assigns[:leave_type] = leave_type
      assigns[:manager] = manager
      assigns[:employee] = employee
    end
  end

  describe 'GET approve_remarks' do
    let(:applied_leave) { create(:apply_leave) }

    it 'assigns information' do
      get :approve_remarks, id: applied_leave.id
      assigns[:applied_leave].should == applied_leave
    end
  end

  describe 'GET deny_remarks' do
    let(:applied_leave) { create(:apply_leave) }

    it 'assigns information' do
      get :deny_remarks, id: applied_leave.id
      assigns[:applied_leave].should == applied_leave
    end
  end

  describe 'GET approve_leave' do
    let(:applied_leave) { create(:apply_leave, employee_id: employee.id) }
    let(:employee) { create(:employee, reporting_manager_id: manager) }
    let(:manager) { create(:employee).id }
    let(:params) { { applied_leave: applied_leave.id } }

    it 'calculates reset count' do
      ApplyLeave.any_instance.expects(:calculate_reset_count)
      get :approve_leave, params
      response.should redirect_to(action: :leaves, id: manager)
      flash[:notice].should be_present
    end
  end

  describe 'GET deny_leave' do
    let(:applied_leave) { create(:apply_leave, employee_id: employee.id) }
    let(:employee) { create(:employee, reporting_manager_id: manager) }
    let(:manager) { create(:employee).id }
    let(:manager_remark) { 'manager_remark' }
    let(:params) do
      {
        applied_leave: applied_leave.id,
        manager_remark: manager_remark
      }
    end

    it 'denies leave' do
      ApplyLeave.any_instance.expects(:deny).with(manager_remark)
      get :deny_leave, params
      response.should redirect_to(action: :leaves, id: manager)
      flash[:notice].should be_present
    end
  end

  describe 'GET cancel' do
    it 'renders blank text' do
      get :cancel
      response.should render_template(text: '')
    end
  end

  describe 'GET new_leave_applications' do
    let(:employee) { create(:employee) }
    let!(:reporting_employees) { create_list(:employee, 2, reporting_manager_id: employee.id) }

    it 'assigns leave' do
      get :new_leave_applications, id: employee.id
      assigns[:employee].should == employee
      assigns[:reporting_employees].should == reporting_employees
    end

    it 'renders partial' do
      get :new_leave_applications, id: employee.id
      response.should render_template(partial: 'new_leave_applications')
    end
  end

  describe 'GET all_employee_new_leave_applications' do
    let(:employee) { create(:employee) }
    let!(:employees) { create_list(:employee, 2, reporting_manager_id: employee.id) }

    it 'assigns leave' do
      get :all_employee_new_leave_applications, id: employee.id
      assigns[:employee].should == employee
      assigns[:all_employees].should == Employee.all
    end

    it 'renders partial' do
      get :all_employee_new_leave_applications, id: employee.id
      response.should render_template(partial: 'all_employee_new_leave_applications')
    end
  end

  describe 'GET all_leave_applications' do
    let(:employee) { create(:employee) }
    let!(:employees) { create_list(:employee, 2, reporting_manager_id: employee.id) }

    it 'assigns leave' do
      get :all_leave_applications, id: employee.id
      assigns[:employee].should == employee
      assigns[:reporting_employees].should == employees
    end

    it 'renders partial' do
      get :all_leave_applications, id: employee.id
      response.should render_template(partial: 'all_leave_applications')
    end
  end

  describe 'GET individual_leave_applications' do
    let(:employee) { create(:employee) }
    let!(:applied_leaves) do
      create_list(:apply_leave, 2,
                  approved: false,
                  viewed_by_manager: false,
                  employee_id: employee.id)
    end

    it 'assigns leave' do
      get :individual_leave_applications, id: employee.id
      assigns[:employee].should == employee
      assigns[:pending_applied_leaves].should == applied_leaves
    end

    it 'renders partial' do
      get :individual_leave_applications, id: employee.id
      response.should render_template(partial: 'individual_leave_applications')
    end
  end

  describe 'GET own_leave_application' do
    let(:apply_leave) do
      create(:apply_leave,
             employee_leave_type_id: leave_type.id,
             employee_id: employee.id)
    end
    let(:leave_type) { create(:employee_leave_type) }
    let(:employee) { create(:employee) }

    before do
      employee.user = @user
      employee.save
    end

    it 'assigns information' do
      get :own_leave_application, id: apply_leave.id
      assigns[:applied_leave].should == apply_leave
      assigns[:leave_type].should == leave_type
      assigns[:employee].should == employee
    end
  end

  describe 'GET cancel_application' do
    let(:employee) { create(:employee) }
    let(:viewed_by_manager) { true }
    let!(:apply_leave) do
      create(:apply_leave,
             viewed_by_manager: viewed_by_manager,
             employee_id: employee.id)
    end

    before do
      employee.user = @user
      employee.save
    end

    context 'always' do
      it 'redirects to leaves page' do
        get :cancel_application, id: apply_leave.id
        response.should redirect_to(action: :leaves, id: employee.id)
      end
    end

    context 'when applied leave is not viewed by manager' do
      let(:viewed_by_manager) { false}

      it 'destroys applied leave' do
        expect {
          get :cancel_application, id: apply_leave.id
        }.to change { ApplyLeave.count }.by(-1)
      end
    end

    context 'when applied leave is viewed by manager' do
      it 'does not destroy applied leave' do
        expect {
          get :cancel_application, id: apply_leave.id
        }.to_not change { ApplyLeave.count }
      end
    end
  end

  describe 'GET update_all_application_view' do

    context 'when employee id is blank' do
      let(:employee_id) { '' }
      before { get :update_all_application_view, employee_id: employee_id }

      it 'renders blank page' do
        response.should have_rjs(replace_html: 'all-application-view')
        response.should render_template(text: '')
      end
    end

    context 'when employee id is not blank' do
      let(:employee) { create(:employee) }
      let(:employee_id) { employee.id }
      let!(:pending_leaves) do
        create_list(:apply_leave, 2,
                    employee_id: employee.id,
                    approved: false,
                    viewed_by_manager: false)
      end

      before { get :update_all_application_view, employee_id: employee_id }

      it 'renders blank page' do
        response.should have_rjs(replace_html: 'all-application-view')
        response.should render_template(partial: 'all_leave_application_lists')
      end

      it 'assigns information' do
        assigns[:employee].should == employee
        assigns[:all_pending_applied_leaves].should == pending_leaves
      end
    end
  end

  describe 'GET employee_attendance_pdf' do
    let(:employee) { create(:employee) }
    let(:attendance_report) { create_list(:employee_attendance, 2, employee_id: employee.id) }
    let(:leave_types) { create_list(:employee_leave_type, 2, status: true) }

    before { get :employee_attendance_pdf, id: employee.id }

    it 'assigns information' do
      assigns[:employee].should == employee
      assigns[:leave_types].should == leave_types
      assigns[:attendance_report].should == attendance_report
      assigns[:total_leaves].should == 0
    end

    it 'renders pdf' do
      response.should render_template(pdf: 'employee_attendance_pdf')
    end
  end
end
