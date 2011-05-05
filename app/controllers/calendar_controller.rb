class CalendarController < ApplicationController
  before_filter :login_required
  filter_access_to :event_delete
  def index
    @user = current_user
    if params[:new_month].nil?
      @show_month = Date.today
    else
      d = params[:new_month].to_i
      passed_date = (params[:passed_date]).to_date
      if params[:new_month].to_i > passed_date.month
        @show_month  = passed_date+1.month
      else
        @show_month = passed_date-1.month
      end      
    end    
    @start_date = @show_month.beginning_of_month
    @start_date_day = @start_date.wday
    @last_day = @show_month.end_of_month
  end

  def new_calendar
    @user = current_user
    d = params[:new_month].to_i
    passed_date = (params[:passed_date]).to_date
    if params[:new_month].to_i > passed_date.month
      @show_month  = passed_date+1.month
    else
      @show_month = passed_date-1.month
    end
    @start_date = @show_month.beginning_of_month
    @start_date_day = @start_date.wday
    @last_day = @show_month.end_of_month
    render :update do |page|
      page.replace_html 'calendar', :partial => 'month',:object => @show_month
      page.replace_html :tooltip_header, :text => ''
    end
  end

  #  def view
  #    @user = current_user
  #    date = params[:id].to_date
  #    first_day = date.beginning_of_month.to_time
  #    last_day = date.end_of_month.to_time
  #    common_event = Event.find_all_by_is_common(true, :conditions => ["(start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)", first_day, last_day, first_day,last_day])
  #    @common_event_array = []
  #    common_event.each do |h|
  #      if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
  #        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == date
  #          @common_event_array.push h
  #        end
  #      else
  #        ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
  #          @common_event_array.push(h) if d == date
  #        end
  #      end
  #    end
  #    not_common_event = Event.find_all_by_is_common(false, :conditions => ["(start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)", first_day, last_day, first_day,last_day])
  #    if @user.student == true
  #      user_student = Student.find_by_admission_no(@user.username)
  #      course = user_student.course
  #      @student_course_not_common_event_array = []
  #      not_common_event.each do |h|
  #        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
  #          if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == date
  #            student_course_event = CourseEvent.find_by_course_id(course.id, :conditions=>"event_id = #{h.id}")
  #            @student_course_not_common_event_array.push(h) unless student_course_event.nil?
  #          end
  #        else
  #          ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
  #            if d == date
  #              student_course_event = CourseEvent.find_by_course_id(course.id, :conditions=>"event_id = #{h.id}")
  #              @student_course_not_common_event_array.push(h) unless student_course_event.nil?
  #            end
  #          end
  #        end
  #      end
  #    else
  #      user_employee = Employee.find_by_employee_number(@user.username)
  #      department = user_employee.employee_department
  #      @employee_dept_not_common_event_array = []
  #      not_common_event.each do |h|
  #        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
  #          if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == date
  #            employee_dept_event = EmployeeDepartmentEvent.find_by_employee_department_id(department.id, :conditions=>"event_id = #{h.id}")
  #            unless employee_dept_event.nil?
  #              @employee_dept_not_common_event_array.push h
  #            end
  #          end
  #        else
  #          ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
  #            if d == date
  #              employee_dept_event = EmployeeDepartmentEvent.find_by_employee_department_id(department.id, :conditions=>"event_id = #{h.id}")
  #              @employee_dept_not_common_event_array.push(h) unless employee_dept_event.nil?
  #            end
  #          end
  #        end
  #      end
  #    end
  #    render :update do |page|
  #      page.replace_html 'modal-box', :partial => 'view'
  #      page << "Modalbox.show($('modal-box'), {title: '#{date}', width: 500});"
  #    end
  #  end

  #  def programs
  #    @day = params[:day]
  #    render :update do |page|
  #      page.replace_html 'modal-box', :partial => 'calendar_day_view'
  #      page << "Modalbox.show($('modal-box'), {title: 'Set fee collection date', width: 500});"
  #    end
  #  end

  #  def show_exam_tooltip
  #    @user = current_user
  #    date = params[:id].to_date
  #
  #    if @user.student ==true
  #      user_student = Student.find_by_admission_no(@user.username)
  #      course = user_student.course
  #      subjects = course.subjects
  #      @examination_array = []
  #      subjects.each do |s|
  #        current_date_exam = Examination.find_by_subject_id_and_date(s.id, date)
  #        @examination_array.push(current_date_exam) unless current_date_exam.nil?
  #      end
  #    else
  #      @examination = Examination.find_all_by_date(date)
  #    end
  #  end

  #  def show_common_event_tooltip
  #    @user = current_user
  #    @date = params[:id].to_date
  #    first_day = @date.beginning_of_month.to_time
  #    last_day = @date.end_of_month.to_time
  #    common_event = Event.find_all_by_is_common_and_is_holiday(true,false, :conditions => ["(start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)", first_day, last_day, first_day,last_day])
  #    @common_event_array = []
  #    common_event.each do |h|
  #      if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
  #        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
  #          @common_event_array.push h
  #        end
  #      else
  #        ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
  #          if d == @date
  #            @common_event_array.push h
  #          end
  #        end
  #      end
  #    end
  #  end

  #  def show_common_holiday_event_tooltip
  #    @user = current_user
  #    @date = params[:id].to_date
  #    first_day = @date.beginning_of_month.to_time
  #    last_day = @date.end_of_month.to_time
  #    common_holiday_event = Event.find_all_by_is_common_and_is_holiday(true,true, :conditions => ["(start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)", first_day, last_day, first_day,last_day])
  #    @common_holiday_event_array = []
  #    common_holiday_event.each do |h|
  #      if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
  #        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
  #          @common_holiday_event_array.push h
  #        end
  #      else
  #        ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
  #          if d == @date
  #            @common_holiday_event_array.push h
  #          end
  #        end
  #      end
  #    end
  #  end

  def show_event_tooltip
    @user = current_user
    @date = params[:id].to_date
    first_day = @date.beginning_of_month.to_time
    last_day = @date.end_of_month.to_time

    common_event = Event.find_all_by_is_common_and_is_holiday(true,false, :conditions => ["(start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)", first_day, last_day, first_day,last_day])
    non_common_events = Event.find_all_by_is_common_and_is_holiday_and_is_exam(false,false,false, :conditions => ["(start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)", first_day, last_day, first_day,last_day])
    @common_event_array = []
    common_event.each do |h|
      if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
          @common_event_array.push h
        end
      else
        ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
          if d == @date
            @common_event_array.push h
          end
        end
      end
    end
    if @user.student == true
      user_student = Student.find_by_admission_no(@user.username)
      batch = user_student.batch
      @student_batch_not_common_event_array = []
      non_common_events.each do |h|
        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
          if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
            student_batch_event = BatchEvent.find_by_batch_id(batch.id, :conditions=>"event_id = #{h.id}")
            @student_batch_not_common_event_array.push(h) unless student_batch_event.nil?
          end
        else
          ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
            if d == @date
              student_batch_event = BatchEvent.find_by_batch_id(batch.id, :conditions=>"event_id = #{h.id}")
              @student_batch_not_common_event_array.push(h) unless student_batch_event.nil?
            end
          end
        end
      end
      @events = @common_event_array + @student_batch_not_common_event_array
    elsif @user.employee == true
      user_employee = Employee.find_by_employee_number(@user.username)
      department = user_employee.employee_department
      @employee_dept_not_common_event_array = []
      non_common_events.each do |h|
        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
          if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
            employee_dept_event = EmployeeDepartmentEvent.find_by_employee_department_id(department.id, :conditions=>"event_id = #{h.id}")
            @employee_dept_not_common_event_array.push(h) unless employee_dept_event.nil?
          end
        else
          ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
            if d == @date
              employee_dept_event = EmployeeDepartmentEvent.find_by_employee_department_id(department.id, :conditions=>"event_id = #{h.id}")
              @employee_dept_not_common_event_array.push(h) unless employee_dept_event.nil?
            end
          end
        end
      end
      @events = @common_event_array + @employee_dept_not_common_event_array
    elsif @user.admin == true
      @employee_dept_not_common_event_array = []
      non_common_events.each do |h|
        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
          if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
            employee_dept_event = EmployeeDepartmentEvent.find(:all, :conditions=>"event_id = #{h.id}")
            @employee_dept_not_common_event_array.push(h) unless employee_dept_event.nil?
          end
        else
          ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
            if d == @date
              employee_dept_event = EmployeeDepartmentEvent.find(:all, :conditions=>"event_id = #{h.id}")
              @employee_dept_not_common_event_array.push(h) unless employee_dept_event.nil?
            end
          end
        end
      end
      @events = @common_event_array + @employee_dept_not_common_event_array
    end
  end

  def show_holiday_event_tooltip
    @user = current_user
    @date = params[:id].to_date
    first_day = @date.beginning_of_month.to_time
    last_day = @date.end_of_month.to_time

    common_holiday_event = Event.find_all_by_is_common_and_is_holiday(true,true, :conditions => ["(start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)", first_day, last_day, first_day,last_day])
    non_common_holiday_events = Event.find_all_by_is_common_and_is_holiday(false,true, :conditions => ["(start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)", first_day, last_day, first_day,last_day])
    @common_holiday_event_array = []
    common_holiday_event.each do |h|
      if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
          @common_holiday_event_array.push h
        end
      else
        ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
          if d == @date
            @common_holiday_event_array.push h
          end
        end
      end
    end
    if @user.student == true
      user_student = Student.find_by_admission_no(@user.username)
      batch = user_student.batch unless user_student.nil?
      @student_batch_not_common_holiday_event_array = []
      non_common_holiday_events.each do |h|
        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
          if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
            student_batch_holiday_event = BatchEvent.find_by_batch_id(batch.id, :conditions=>"event_id = #{h.id}")
            @student_batch_not_common_holiday_event_array.push(h) unless student_batch_holiday_event.nil?
          end
        else
          ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
            if d == @date
              student_batch_holiday_event = BatchEvent.find_by_batch_id(batch.id, :conditions=>"event_id = #{h.id}")
              @student_batch_not_common_holiday_event_array.push(h) unless student_batch_holiday_event.nil?
            end
          end
        end
      end
      @events = @common_holiday_event_array.to_a + @student_batch_not_common_holiday_event_array.to_a
    elsif  @user.employee == true
      user_employee = Employee.find_by_employee_number(@user.username)
      department = user_employee.employee_department unless user_employee.nil?
      @employee_dept_not_common_holiday_event_array = []
      non_common_holiday_events.each do |h|
        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
          if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
            employee_dept_holiday_event = EmployeeDepartmentEvent.find_by_employee_department_id(department.id, :conditions=>"event_id = #{h.id}")
            @employee_dept_not_common_holiday_event_array.push(h) unless employee_dept_holiday_event.nil?
          end
        else
          ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
            if d == @date
              employee_dept_holiday_event = EmployeeDepartmentEvent.find_by_employee_department_id(department.id, :conditions=>"event_id = #{h.id}")
              @employee_dept_not_common_holiday_event_array.push(h) unless employee_dept_holiday_event.nil?
            end
          end
        end
      end
      @events = @common_holiday_event_array.to_a + @employee_dept_not_common_holiday_event_array.to_a
    elsif  @user.admin == true
      @employee_dept_not_common_holiday_event_array = []
      non_common_holiday_events.each do |h|
        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
          if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
            employee_dept_holiday_event = EmployeeDepartmentEvent.find(:all, :conditions=>"event_id = #{h.id}")
            @employee_dept_not_common_holiday_event_array.push(h) unless employee_dept_holiday_event.nil?
          end
        else
          ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
            if d == @date
              employee_dept_holiday_event = EmployeeDepartmentEvent.find(:all, :conditions=>"event_id = #{h.id}")
              @employee_dept_not_common_holiday_event_array.push(h) unless employee_dept_holiday_event.nil?
            end
          end
        end
      end
      @events = @common_holiday_event_array.to_a + @employee_dept_not_common_holiday_event_array.to_a
    end
  end

  def show_exam_event_tooltip
    @user = current_user
    @date = params[:id].to_date
    first_day = @date.beginning_of_month.to_time
    last_day = @date.end_of_month.to_time
    not_common_exam_event = Event.find_all_by_is_common_and_is_holiday_and_is_exam(false,false,true, :conditions => ["(start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)", first_day, last_day, first_day,last_day])
    @student_batch_exam_event_array = []
    if @user.student == true
      user_student = Student.find_by_admission_no(@user.username)
      batch = user_student.batch
      not_common_exam_event.each do |h|
        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
          if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
            student_batch_exam_event = BatchEvent.find_by_batch_id(batch.id, :conditions=>"event_id = #{h.id}")
            unless student_batch_exam_event.nil?
              @student_batch_exam_event_array.push h
            end
          end
        else
          ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
            if d == @date
              student_batch_exam_event = BatchEvent.find_by_batch_id(batch.id, :conditions=>"event_id = #{h.id}")
              unless student_batch_exam_event.nil?
                @student_batch_exam_event_array.push h
              end
            end
          end
        end
      end
    else
      not_common_exam_event.each do |h|
        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
          if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
            #            student_batch_exam_event = BatchEvent.find_by_batch_id(batch.id, :conditions=>"event_id = #{h.id}")
            #            unless student_batch_exam_event.nil?
            @student_batch_exam_event_array.push h
            #            end
          end
        else
          ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
            if d == @date
              #              student_batch_exam_event = BatchEvent.find_by_batch_id(batch.id, :conditions=>"event_id = #{h.id}")
              #              unless student_batch_exam_event.nil?
              @student_batch_exam_event_array.push h
              #              end
            end
          end
        end
      end
    end
  end

  def show_due_tooltip
    @user = current_user
    @date = params[:id].to_date
    first_day = @date.beginning_of_month.to_time
    last_day = @date.end_of_month.to_time

    finance_due_check = Event.find_all_by_is_due(true,true, :conditions => ["(start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)", first_day, last_day, first_day,last_day])
    @finance_due = []
    finance_due_check.each do |h|
      if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == "#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date
        if "#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date == @date
          @finance_due.push h
        end
      else
        ("#{h.start_date.year}-#{h.start_date.month}-#{h.start_date.day}".to_date.."#{h.end_date.year}-#{h.end_date.month}-#{h.end_date.day}".to_date).each do |d|
          if d == date
            @finance_due.push h
          end
        end
      end
    end
  
  end

  def event_delete
    @event = Event.find_by_id(params[:id])
    #unless @event.is_common == false
      @event.destroy unless @event.nil?
   # end
    redirect_to :controller=>"calendar"
  end

end