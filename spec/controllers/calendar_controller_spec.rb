require 'spec_helper'

describe CalendarController do
  before do
    @user  = Factory.create(:admin_user)
    @calendar_events = FactoryGirl.create(:event)

    sign_in(@user)
  end

  describe 'GET #index' do
    context 'params[:new_month] is nil' do
      before do
        get :index
      end

      it 'renders the index template' do
        response.should render_template('index')
      end

      it 'assigns all events as @events' do
        assigns(:events).should == [@calendar_events]
      end
    end
  end

  describe 'POST #new_calendar' do
    context 'params[:new_month] is nil' do
      before do
        post :new_calendar, :new_month => '10', :passed_date => Date.current
      end

      it 'renders the index template' do
        response.should render_template(:partial => 'month')
      end

      it 'assigns all events as @events' do
        #debugger
        assigns(:events).should == [@calendar_events]
      end
    end
  end
end