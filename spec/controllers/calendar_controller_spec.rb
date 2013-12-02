require 'spec_helper'

describe CalendarController do
  describe 'GET #index' do
    context 'returns template' do
      before do
        @user  = Factory.create(:admin_user)
        sign_in(@user)
        get :index
      end

      it 'renders the index template' do
        response.should render_template('index')
      end
    end

    context 'notifications with admin_user' do
      before do
        @user  = Factory.create(:admin_user)
        sign_in(@user)
      end

      context 'e.is_common?' do
        context 'event is a holiday and start_date not equal end_date' do
          before do
            @calendar_events = FactoryGirl.create(:event, :is_common => true, :is_holiday => true)
            @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
            get :index
          end

          it 'assigns all holiday event' do
            assigns(:holiday_event).should == @notifications
          end
        end

        context 'event is not a holiday and start_date equal end_date' do
          before do
            @calendar_events = FactoryGirl.create(:event, 
              :is_common  => true, 
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            @notifications   = @calendar_events.start_date.to_date
            get :index
          end

          it 'assigns all event' do
            assigns(:events).should == [@notifications]
          end
        end
      end

      context 'e.is_due?' do
        before do
          @calendar_events = FactoryGirl.create(:event, :is_due  => true)
          @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
          get :index
        end

        it 'assigns all finance_due notifications' do
          assigns(:notifications)["finance_due"].should == @notifications
        end
      end

      context 'e.is_common? && e.is_holiday?' do
        before do
          @calendar_events = FactoryGirl.create(:event, 
            :is_common  => true,
            :is_holiday => true)
          @employee_dept   = FactoryGirl.create(:employee_department_event, :event => @calendar_events)
          @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
          get :index
        end

        it 'assigns all notifications' do
          assigns(:holiday_event).should include(*@notifications)
        end
      end

      context 'e.is_common? && e.is_holiday? && e.is_exam?' do
        before do
          @batch           = FactoryGirl.create(:batch)
          @finance_fee_co  = FactoryGirl.create(:finance_fee_collection, :batch => @batch)
          @calendar_events = FactoryGirl.create(:event, 
            :is_common  => true,
            :is_holiday => true,
            :is_exam    => true,
            :origin => @finance_fee_co)
          FactoryGirl.create(:batch_event, :event => @calendar_events, :batch => @batch)
          @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
          get :index
        end

        it 'assigns all notifications' do
          assigns(:notifications)["student_batch_exam"].should == @notifications
        end
      end

      context 'e.is_common? && e.is_holiday? && e.is_due? && e.is_exam?' do
        before do
          @calendar_events = FactoryGirl.create(:event, 
            :is_common  => true,
            :is_holiday => true,
            :is_exam    => true,
            :is_due     => true)
          @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
          get :index
        end

        it 'assigns all notifications' do
          assigns(:notifications)["employee_dept_not_common"].should == @notifications
        end
      end
    end

    context 'notifications with employee_user' do
      before do
        @user  = Factory.create(:employee_user)
        sign_in(@user)
      end

      context 'e.is_due?' do
        context 'employee event is found' do
          before do
            @calendar_events = FactoryGirl.create(:event, :is_due  => true)
            FactoryGirl.create(:user_event, :event => @calendar_events, :user => @user)
            @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
            get :index
          end

          it 'assigns all finance_due notifications' do
            assigns(:notifications)["finance_due"].should == @notifications
          end
        end

        context 'employee event is found' do
          before do
            @calendar_events = FactoryGirl.create(:event, :is_due  => true)
            @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
            get :index
          end

          it 'assigns all finance_due notifications' do
            assigns(:notifications)["finance_due"].should_not == @notifications
          end
        end
      end

      context 'e.is_common? && e.is_holiday?' do
        before do
          @employee_dept    = FactoryGirl.create(:employee_department)
          @employee         = FactoryGirl.create(:employee, :employee_department_id => @employee_dept.id)
          @calendar_events  = FactoryGirl.create(:event, 
            :is_common  => true,
            :is_holiday => true)
          FactoryGirl.create(:employee_department_event, 
            :event => @calendar_events, 
            :employee_department => @employee_dept)
          @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
          sign_in(@employee.user)

          get :index
        end

        it 'assigns all notifications' do
          assigns(:notifications)['employee_dept_not_common_holiday'].should == @notifications
        end
      end

      context 'e.is_common? && e.is_holiday? && e.is_exam?' do
        before do
          @employee_dept    = FactoryGirl.create(:employee_department)
          @employee         = FactoryGirl.create(:employee, :employee_department_id => @employee_dept.id)
          @finance_fee_co   = FactoryGirl.create(:finance_fee_collection)
          @calendar_events  = FactoryGirl.create(:event, 
            :is_common  => true,
            :is_holiday => true,
            :is_exam    => true,
            :origin     => @finance_fee_co)
          FactoryGirl.create(:employee_department_event, 
            :event => @calendar_events, 
            :employee_department => @employee_dept)
          @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
          sign_in(@employee.user)

          get :index
        end

        it 'assigns all notifications' do
          assigns(:notifications)['student_batch_exam'].should == @notifications
        end
      end

      context 'e.is_common? && e.is_holiday? && e.is_exam? && e.is_due?' do
        context 'start_date is equal to end_date' do
          before do
            @employee_dep     = FactoryGirl.create(:employee_department)
            @employee         = FactoryGirl.create(:employee, :employee_department_id => @employee_dep.id)
            @calendar_events  = FactoryGirl.create(:event, 
              :is_common  => true,
              :is_holiday => true,
              :is_exam    => true,
              :is_due     => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            FactoryGirl.create(:employee_department_event, 
              :event => @calendar_events, 
              :employee_department => @employee_dep)
            @notifications   = @calendar_events.start_date.to_date
            sign_in(@employee.user)

            get :index
          end

          it 'assigns all notifications' do
            assigns(:notifications)["employee_dept_not_common"].should == [@notifications]
          end
        end

        context 'start_date is not equal to end_date' do
          before do
            @employee_dep     = FactoryGirl.create(:employee_department)
            @employee         = FactoryGirl.create(:employee, :employee_department_id => @employee_dep.id)
            @calendar_events  = FactoryGirl.create(:event, 
              :is_common  => true,
              :is_holiday => true,
              :is_exam    => true,
              :is_due     => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            FactoryGirl.create(:employee_department_event, 
              :event => @calendar_events, 
              :employee_department => @employee_dep)
            @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
            sign_in(@employee.user)

            get :index
          end

          it 'assigns all notifications' do
            assigns(:notifications)["employee_dept_not_common"].should == @notifications
          end
        end
      end
    end

    context 'notifications with student_user or parent_user' do
      before do
        @batch   = FactoryGirl.create(:batch)
        @student = Factory.create(:student, :batch => @batch)
        sign_in(@student.user)
      end

      context 'e.is_due?' do
        context 'employee event is found' do
          before do
            @calendar_events = FactoryGirl.create(:event, :is_due  => true)
            FactoryGirl.create(:user_event, :event => @calendar_events, :user => @student.user)
            @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
            get :index
          end

          it 'assigns all finance_due notifications' do
            assigns(:notifications)['finance_due'].should == @notifications
          end
        end

        context 'employee event is found' do
          before do
            @calendar_events = FactoryGirl.create(:event, :is_due  => true)
            @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a
            get :index
          end

          it 'assigns all finance_due notifications' do
            assigns(:notifications)['finance_due'].should_not == @notifications
          end
        end
      end

      context 'e.is_common? && e.is_holiday?' do
        before do
          @calendar_events = FactoryGirl.create(:event, 
              :is_common  => true,
              :is_holiday => true)
            FactoryGirl.create(:batch_event, 
              :event => @calendar_events, 
              :batch => @batch)
          @notifications = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a

          get :index
        end

        it 'assigns all notifications' do
          assigns(:notifications)['student_batch_not_common_holiday'].should == @notifications
        end
      end

      context 'e.is_common? && e.is_holiday? && e.is_exam?' do
        before do
          @exam_group      = FactoryGirl.create(:exam_group)
          @subject         = FactoryGirl.create(:subject, :batch => @batch)
          @calendar_events = FactoryGirl.create(:event, 
            :is_common  => true,
            :is_holiday => true,
            :is_exam    => true,
            :origin     => @exam)
          @exam            = FactoryGirl.create(:exam,
            :event      => @calendar_events, 
            :exam_group => @exam_group,
            :subject    => @subject)
          FactoryGirl.create(:batch_event, 
              :event => @calendar_events, 
              :batch => @batch)
          @notifications   = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a

          get :index
        end

        it 'assigns all notifications' do
          assigns(:notifications)['student_batch_exam'].should == @notifications
        end
      end

      context 'e.is_common? && e.is_holiday? && e.is_exam? && e.is_due?' do
        context 'start_date is equal to end_date' do
          before do
            @calendar_events  = FactoryGirl.create(:event, 
              :is_common  => true,
              :is_holiday => true,
              :is_exam    => true,
              :is_due     => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            FactoryGirl.create(:batch_event, 
              :event => @calendar_events, 
              :batch => @batch)
            @notifications = @calendar_events.start_date.to_date

            get :index
          end

          it 'assigns all notifications' do
            assigns(:notifications)['student_batch_not_common'].should == [@notifications]
          end
        end

        context 'start_date is not equal to end_date' do
          before do
            @calendar_events = FactoryGirl.create(:event, 
              :is_common  => true,
              :is_holiday => true,
              :is_exam    => true,
              :is_due     => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            FactoryGirl.create(:batch_event, 
              :event => @calendar_events, 
              :batch => @batch)
            @notifications = (@calendar_events.start_date.to_date..@calendar_events.end_date.to_date).to_a

            get :index
          end

          it 'assigns all notifications' do
            assigns(:notifications)['student_batch_not_common'].should == @notifications
          end
        end
      end
    end
  end

  describe 'POST #new_calendar' do
    before do
      @user  = Factory.create(:admin_user)
      sign_in(@user)
      @events = Factory.create(:event, :is_common => true)
      @notifications = (@events.start_date.to_date..@events.end_date.to_date).to_a
      post :new_calendar, :new_month => Date.current.month + 1, :passed_date => Date.current
    end

    it 'renders the month partial' do
      response.should render_template(:partial => 'month')
    end

    it 'assigns all events as @events' do
      assigns(:events).should == @notifications
    end
  end

  ####### show_event_tooltip #######
  describe 'POST #show_event_tooltip' do
    context 'common events' do
      before do
        @user  = Factory.create(:admin_user)
        sign_in(@user)
        @events = Factory.create(:event, :is_common => true)
        post :show_event_tooltip, :id => Date.current
      end

      it 'assigns all common events' do
        assigns(:common_event_array).should == [@events]
      end
    end

    context 'non common events' do
      context '@user.student? || @user.parent?' do
        context 'start_date is equal to end_date' do
          before do
            @batch            = FactoryGirl.create(:batch)
            @student          = FactoryGirl.create(:student, :batch => @batch)
            @non_common_event = FactoryGirl.create(:event,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            @common_event     = FactoryGirl.create(:event,
              :is_common => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            FactoryGirl.create(:batch_event,
              :event => @non_common_event,
              :batch => @batch)
            sign_in(@student.user)

            post :show_event_tooltip, :id => Date.current
          end

          it 'assigns all non common events' do
            assigns(:events).should include(@non_common_event)
          end
        end

        context 'start_date is not equal to end_date' do
          before do
            @batch            = FactoryGirl.create(:batch)
            @student          = FactoryGirl.create(:student, :batch => @batch)
            @common_event     = FactoryGirl.create(:event, :is_common => true)
            @non_common_event = FactoryGirl.create(:event)
            FactoryGirl.create(:batch_event,
              :event => @non_common_event,
              :batch => @batch)
            sign_in(@student.user)

            post :show_event_tooltip, :id => Date.current
          end

          it 'assigns all events' do
            assigns(:events).should include(@non_common_event)
          end
        end
      end

      context '@user.employee?' do
        context 'start_date is equal to end_date' do
          before do
            @employee_dept    = FactoryGirl.create(:employee_department)
            @employee         = FactoryGirl.create(:employee, :employee_department => @employee_dept)
            @non_common_event = FactoryGirl.create(:event,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            @common_event     = FactoryGirl.create(:event,
              :is_common => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            FactoryGirl.create(:employee_department_event, 
              :event => @non_common_event, 
              :employee_department => @employee_dept)

            sign_in(@employee.user)

            post :show_event_tooltip, :id => Date.current
          end

          it 'assigns all non common events' do
            assigns(:events).should include(@non_common_event)
          end
        end

        context 'start_date is not equal to end_date' do
          before do
            @employee_dept    = FactoryGirl.create(:employee_department)
            @employee         = FactoryGirl.create(:employee, :employee_department => @employee_dept)
            @non_common_event = FactoryGirl.create(:event)
            @common_event     = FactoryGirl.create(:event, :is_common => true)
            FactoryGirl.create(:employee_department_event, 
              :event               => @non_common_event,
              :employee_department => @employee_dept)

            sign_in(@employee.user)

            post :show_event_tooltip, :id => Date.current
          end

          it 'assigns all non common events' do
            assigns(:events).should include(@non_common_event)
          end
        end
      end

      context '@user.admin?' do
        context 'start_date is equal to end_date' do
          before do
            @user             = FactoryGirl.create(:admin_user) 
            @non_common_event = FactoryGirl.create(:event,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            @common_event     = FactoryGirl.create(:event,
              :is_common  => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            FactoryGirl.create(:employee_department_event, 
              :event      => @non_common_event, 
              :employee_department => FactoryGirl.create(:employee_department))

            sign_in(@user)

            post :show_event_tooltip, :id => Date.current
          end

          it 'assigns all non common events' do
            assigns(:events).should include(@non_common_event)
          end
        end

        context 'start_date is not equal to end_date' do
          before do
            @user             = FactoryGirl.create(:admin_user) 
            @non_common_event = FactoryGirl.create(:event)
            @common_event     = FactoryGirl.create(:event, :is_common  => true)
            FactoryGirl.create(:employee_department_event, 
              :event               => @non_common_event, 
              :employee_department => FactoryGirl.create(:employee_department))

            sign_in(@user)

            post :show_event_tooltip, :id => Date.current
          end

          it 'assigns all non common events' do
            assigns(:events).should include(@non_common_event)
          end
        end
      end
    end
  end

  ####### show_holiday_event_tooltip #######
  describe 'POST #show_holiday_event_tooltip' do
    context 'common holiday events' do
      before do
        @user  = Factory.create(:admin_user)
        sign_in(@user)
        @common_holiday_event     = Factory.create(:event, 
          :is_common => true, 
          :is_holiday => true)
        @non_common_holiday_event = Factory.create(:event, 
          :is_common => false, 
          :is_holiday => true)

        post :show_holiday_event_tooltip, :id => Date.current
      end

      it 'assigns all common holiday events' do
        assigns(:common_holiday_event_array).should == [@common_holiday_event]
      end
    end

    context 'non common events' do
      context '@user.student? || @user.parent?' do
        context 'start_date is equal to end_date' do
          before do
            @batch             = FactoryGirl.create(:batch)
            @student           = FactoryGirl.create(:student, :batch => @batch)
            @non_com_hol_event = FactoryGirl.create(:event,
              :is_holiday => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            @com_hol_event     = FactoryGirl.create(:event,
              :is_common  => true,
              :is_holiday => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            FactoryGirl.create(:batch_event,
              :event => @non_com_hol_event,
              :batch => @batch)
            sign_in(@student.user)

            post :show_holiday_event_tooltip, :id => Date.current
          end

          it 'assigns all non common holiday events' do
            assigns(:events).should include(@non_com_hol_event)
          end
        end

        context 'start_date is not equal to end_date' do
          before do
            @batch             = FactoryGirl.create(:batch)
            @student           = FactoryGirl.create(:student, :batch => @batch)
            @com_hol_event     = FactoryGirl.create(:event, :is_common => true, :is_holiday => true)
            @non_com_hol_event = FactoryGirl.create(:event, :is_holiday => true)
            FactoryGirl.create(:batch_event,
              :event => @non_com_hol_event,
              :batch => @batch)
            sign_in(@student.user)

            post :show_holiday_event_tooltip, :id => Date.current
          end

          it 'assigns all common holiday events' do
            assigns(:events).should include(@non_com_hol_event)
          end
        end
      end

      context '@user.employee?' do
        context 'start_date is equal to end_date' do
          before do
            @employee_dept     = FactoryGirl.create(:employee_department)
            @employee          = FactoryGirl.create(:employee, :employee_department => @employee_dept)
            @non_com_hol_event = FactoryGirl.create(:event,
              :is_holiday => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            @com_hol_event     = FactoryGirl.create(:event,
              :is_common  => true,
              :is_holiday => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            FactoryGirl.create(:employee_department_event, 
              :event => @non_com_hol_event, 
              :employee_department => @employee_dept)

            sign_in(@employee.user)

            post :show_holiday_event_tooltip, :id => Date.current
          end

          it 'assigns all non common holiday events' do
            assigns(:events).should include(@non_com_hol_event)
          end
        end

        context 'start_date is not equal to end_date' do
          before do
            @employee_dept     = FactoryGirl.create(:employee_department)
            @employee          = FactoryGirl.create(:employee, :employee_department => @employee_dept)
            @non_com_hol_event = FactoryGirl.create(:event, :is_holiday => true)
            @com_hol_event     = FactoryGirl.create(:event, :is_common => true, :is_holiday => true)
            FactoryGirl.create(:employee_department_event, 
              :event               => @non_com_hol_event,
              :employee_department => @employee_dept)

            sign_in(@employee.user)

            post :show_holiday_event_tooltip, :id => Date.current
          end

          it 'assigns all non common holiday events' do
            assigns(:events).should include(@non_com_hol_event)
          end
        end
      end

      context '@user.admin?' do
        context 'start_date is equal to end_date' do
          before do
            @user              = FactoryGirl.create(:admin_user) 
            @non_com_hol_event = FactoryGirl.create(:event, 
              :is_holiday => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            @com_hol_event     = FactoryGirl.create(:event,
              :is_common  => true,
              :is_holiday => true,
              :start_date => Date.current.to_datetime,
              :end_date   => Date.current.to_datetime)
            FactoryGirl.create(:employee_department_event, 
              :event      => @non_com_hol_event, 
              :employee_department => FactoryGirl.create(:employee_department))

            sign_in(@user)

            post :show_holiday_event_tooltip, :id => Date.current
          end

          it 'assigns all non common holiday events' do
            assigns(:events).should include(@non_com_hol_event)
          end
        end

        context 'start_date is not equal to end_date' do
          before do
            @user              = FactoryGirl.create(:admin_user) 
            @non_com_hol_event = FactoryGirl.create(:event, :is_holiday => true)
            @com_hol_event     = FactoryGirl.create(:event, :is_common  => true, :is_holiday => true)
            FactoryGirl.create(:employee_department_event, 
              :event               => @non_com_hol_event, 
              :employee_department => FactoryGirl.create(:employee_department))

            sign_in(@user)

            post :show_holiday_event_tooltip, :id => Date.current
          end

          it 'assigns all non common holiday events' do
            assigns(:events).should include(@non_com_hol_event)
          end
        end
      end
    end
  end

  ####### show_exam_event_tooltip #######
  describe 'POST #show_exam_event_tooltip' do
    context '@user.student? || @user.parent?' do
      context 'start_date is equal to end_date' do
        before do
          @batch          = FactoryGirl.create(:batch)
          @student        = FactoryGirl.create(:student, :batch => @batch)
          @finance_fee_co = FactoryGirl.create(:finance_fee_collection)
          @non_exam_event = FactoryGirl.create(:event,
            :is_exam    => true,
            :start_date => Date.current.to_datetime,
            :end_date   => Date.current.to_datetime,
            :origin     => @finance_fee_co)
          @exam_event     = FactoryGirl.create(:event,
            :is_exam    => true,
            :start_date => Date.current.to_datetime,
            :end_date   => Date.current.to_datetime)
          FactoryGirl.create(:batch_event,
            :event => @non_exam_event,
            :batch => @batch)
          sign_in(@student.user)

          post :show_exam_event_tooltip, :id => Date.current
        end

        it 'assigns all non exam events' do
          assigns(:student_batch_exam_event_array).should include(@non_exam_event)
        end
      end

      context 'start_date is not equal to end_date' do
        before do
          @batch          = FactoryGirl.create(:batch)
          @student        = FactoryGirl.create(:student, :batch => @batch)
          @finance_fee_co = FactoryGirl.create(:finance_fee_collection)
          @non_exam_event = FactoryGirl.create(:event,
            :is_exam    => true,
            :origin     => @finance_fee_co)
          @exam_event     = FactoryGirl.create(:event, :is_exam => true)
          FactoryGirl.create(:batch_event,
            :event => @non_exam_event,
            :batch => @batch)
          sign_in(@student.user)

          post :show_exam_event_tooltip, :id => Date.current
        end

        it 'assigns all exam events' do
          assigns(:student_batch_exam_event_array).should include(@non_exam_event)
        end
      end
    end

    context '@user.admin? || @user.employee?' do
      context 'start_date is equal to end_date' do
        before do
          @user           = FactoryGirl.create(:admin_user)
          @finance_fee_co = FactoryGirl.create(:finance_fee_collection)
          @non_exam_event = FactoryGirl.create(:event,
            :is_exam    => true,
            :start_date => Date.current.to_datetime,
            :end_date   => Date.current.to_datetime,
            :origin     => @finance_fee_co)
          @exam_event     = FactoryGirl.create(:event,
            :is_exam    => true,
            :start_date => Date.current.to_datetime,
            :end_date   => Date.current.to_datetime)

          sign_in(@user)

          post :show_exam_event_tooltip, :id => Date.current
        end

        it 'assigns all non exam events' do
          assigns(:student_batch_exam_event_array).should include(@non_exam_event)
        end
      end

      context 'start_date is not equal to end_date' do
        before do
          @user           = FactoryGirl.create(:admin_user)
          @finance_fee_co = FactoryGirl.create(:finance_fee_collection)
          @non_exam_event = FactoryGirl.create(:event,
            :is_exam    => true,
            :origin     => @finance_fee_co)
          @exam_event     = FactoryGirl.create(:event, :is_exam => true)
          sign_in(@user)

          post :show_exam_event_tooltip, :id => Date.current
        end

        it 'assigns all non exam events' do
          assigns(:student_batch_exam_event_array).should include(@non_exam_event)
        end
      end
    end
  end

   ####### show_due_tooltip #######
  describe 'POST #show_due_tooltip' do
    context '@user.student? || @user.parent?' do
      before do
        @batch          = FactoryGirl.create(:batch)
        @student        = FactoryGirl.create(:student, :batch => @batch)
        @finance_fee_co = FactoryGirl.create(:finance_fee_collection, :batch => @batch)
        FactoryGirl.create(:finance_fee, :finance_fee_collection => @finance_fee_co, :student => @student)
        @finance_due_event = FactoryGirl.create(:event,
          :is_due     => true,
          :origin     => @finance_fee_co,
          :start_date => Date.current.to_datetime,
          :end_date   => Date.current.to_datetime)

        sign_in(@student.user)

        post :show_due_tooltip, :id => Date.current
      end

      it 'assigns all due events' do
        assigns(:finance_due).should include(@finance_due_event)
      end
    end

    context '@user.employee?' do
      before do
        @employee       = FactoryGirl.create(:employee)
        @finance_fee_co = FactoryGirl.create(:finance_fee_collection)
        @finance_due_event = FactoryGirl.create(:event,
          :is_due     => true,
          :origin     => @finance_fee_co,
          :start_date => Date.current.to_datetime,
          :end_date   => Date.current.to_datetime)
        FactoryGirl.create(:user_event, :event => @finance_due_event, :user => @employee.user)
        sign_in(@employee.user)

        post :show_due_tooltip, :id => Date.current
      end

      it 'assigns all due events' do
        assigns(:finance_due).should include(@finance_due_event)
      end
    end
  end

  context '#event_delete' do
    before do
      @user  = FactoryGirl.create(:admin_user)
      @event = FactoryGirl.create(:event)
      sign_in(@user)

      get :event_delete, :id => @event.id
    end

    it 'redirects to calendar' do
      response.should redirect_to(:controller => 'calendar')
    end
  end
end