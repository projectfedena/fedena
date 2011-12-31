class AutoLeaveReset
    
  def auto_leave_reset
    reset_status = Configuration.find_by_config_key("AutomaticLeaveReset")
    last_reset = Configuration.find_by_config_key("LastAutoLeaveReset")
    reset_period = Configuration.find_by_config_key("LeaveResetPeriod")
    if reset_status.config_value == '1'
      if last_reset.config_value.nil?
        start_date = Configuration.find_by_config_key("FinancialYearStartDate")
        reset_date = start_date.config_value.to_date + reset_period.config_value.to_i.months
        if reset_date <= Date.today.to_date
          leave_count = EmployeeLeave.all
          leave_count.each do |e|
            leave_type = EmployeeLeaveType.find_by_id(e.employee_leave_type_id)
            if leave_type.status
              default_leave_count = leave_type.max_leave_count
              if leave_type.carry_forward
                leave_taken = e.leave_taken
                available_leave = e.leave_count
                if leave_taken <= available_leave
                  balance_leave = available_leave - leave_taken
                  available_leave = balance_leave.to_f
                  available_leave += default_leave_count.to_f
                  leave_taken = 0
            
                  e.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
                else
                  available_leave = default_leave_count.to_f
                  leave_taken = 0
                          
                  e.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
                end
              else
                available_leave = default_leave_count.to_f
                leave_taken = 0
             
                e.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
              end
            end
          end
          last_reset.update_attributes(:config_value => Date.today.to_date)

        end
      else
        reset_date = last_reset.config_value.to_date + reset_period.config_value.to_i.months
        if reset_date <= Date.today.to_date
          leave_count = EmployeeLeave.all
          leave_count.each do |e|
            leave_type = EmployeeLeaveType.find_by_id(e.employee_leave_type_id)
            if leave_type.status
              default_leave_count = leave_type.max_leave_count
              if leave_type.carry_forward
                leave_taken = e.leave_taken
                available_leave = e.leave_count
                if leave_taken <= available_leave
                  balance_leave = available_leave - leave_taken
                  available_leave = balance_leave.to_f
                  available_leave += default_leave_count.to_f
                  leave_taken = 0
                          
                  e.update_attributes(:leave_taken => leave_taken,:leave_count => available_leave, :reset_date => Date.today)
                else
                  available_leave = default_leave_count.to_f
                  leave_taken = 0
       
                  e.update_attributes(:leave_taken => 0.0,:leave_count => available_leave, :reset_date => Date.today)
                end
              else
                available_leave = default_leave_count.to_f
                leave_taken = 0
                 
                e.update_attributes(:leave_taken => 0.0,:leave_count => available_leave, :reset_date => Date.today)
              end
            end
          end
          last_reset.update_attributes(:config_value => Date.today.to_date)
        end
      end
    end
  end

end

