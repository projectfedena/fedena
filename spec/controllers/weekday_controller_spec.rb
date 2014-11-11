require 'spec_helper'

describe WeekdayController do
  before do
    @user = FactoryGirl.create(:admin_user)
    @weekday  = Weekday.new
    @batch = Batch.new
    Batch.stub(:find).with('1').and_return(@batch)
    @batch.stub(:is_deleted).and_return(false)

    sign_in(@user)
  end

  describe '#Get index' do
    before do
      Batch.stub(:active).and_return([@batch])
      Weekday.stub(:default).and_return([@weekday])
      get :index
    end

    it 'renders the index template' do
      response.should render_template('index')
    end

    it 'assigns @batches' do
      assigns(:batches).should == [@batch]
    end

    it 'assigns @weekdays' do
      assigns(:weekdays).should == [@weekday]
    end
  end

  describe 'POST #week' do
    context 'batch_id is not nil' do
      before do
        @weekday = FactoryGirl.create(:weekday, :batch_id => '1')
        post :week, :batch_id => @weekday.batch_id.to_param
      end

      it 'assigns @weekdays' do
        assigns(:weekdays).should == [@weekday]
      end

      it 'renders the weekday partial' do
        response.should render_template(:partial => 'weekdays')
      end
    end

    context 'batch_id is nil' do
      before do
        @weekday = FactoryGirl.create(:weekday, :batch_id => '')
        post :week, :batch_id => @weekday.batch_id.to_param
      end

      it 'assigns @weekdays' do
        assigns(:weekdays).should == [@weekday]
      end

      it 'renders the weekday partial' do
        response.should render_template(:partial => 'weekdays')
      end
    end
  end

  describe 'POST #create' do
    context 'successful create' do
      context 'the day is added to weekday' do
        before do
          @days = ['0', '1', '2']
          post :create, :weekday => { :batch_id => '1' }, :weekdays => @days
        end

        it 'returns weekdays' do
          @weekdays = Weekday.for_batch('1').map{ |w| w.weekday }
          @weekdays.should == @days
        end

        it 'assigns flash[:notice]' do
          flash[:notice].should == "#{@controller.t('weekdays_modified')}"
        end

        it 'redirects to the index page' do
          response.should redirect_to(:controller => 'weekday', :action => 'index')
        end
      end

      context 'the day is deactivated' do
        before do
          @days = []
          post :create, :weekday => { :batch_id => '1' }, :weekdays => @days
        end

        it 'returns weekdays' do
          @weekdays = Weekday.for_batch('1').map{ |w| w.weekday }
          @weekdays.should == @days
        end

        it 'assigns flash[:notice]' do
          flash[:notice].should == "#{@controller.t('weekdays_modified')}"
        end

        it 'redirects to the index page' do
          response.should redirect_to(:controller => 'weekday', :action => 'index')
        end
      end
    end

    context 'failed create' do
      before do
        get :create
      end

      it 'assigns flash[:notice]' do
        flash[:notice].should == nil
      end

      it 'redirects to the index page' do
        response.should redirect_to(:controller => 'weekday', :action => 'index')
      end
    end
  end
end
