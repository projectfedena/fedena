require 'spec_helper'

describe CoursesController do
  before do
    @user       = Factory.create(:admin_user)
    @course     = FactoryGirl.create(:course)
    sign_in(@user)
  end

  describe 'GET #index' do
    before do
      Course.expects(:active).returns(@course)
      get :index
    end

    it 'renders the index template' do
      response.should render_template('index')
    end
  end

  describe 'GET #show' do
    before do
      get :show, :id => @course
    end

    it 'renders the show template' do
      response.should render_template('show')
    end

    it 'assigns the requested course as @course' do
      assigns(:course).should == @course
    end
  end

  describe 'GET #new' do
    before do
      get :new
    end

    it 'renders the new template' do
      response.should render_template('new')
    end
  end

  describe 'GET #edit' do
    before do
      get :edit, :id => @course
    end

    it 'renders the edit template' do
      response.should render_template('edit')
    end
  end

  describe 'POST #create' do
    before do
      Course.stub(:new).with({ 'these' => 'params' }).and_return(@course)
    end

    context 'successful create' do
      before do
        Course.any_instance.expects(:save).returns(true)
        post :create, :course => { 'these' => 'params' }
      end

      it 'assigns flash[:notice]' do
        flash[:notice].should == "#{@controller.t('flash1')}"
      end

      it 'redirects to the manage_course' do
        response.should redirect_to(:controller => "courses", :action => "manage_course")
      end
    end

    context 'failed create' do
      before do
        Course.any_instance.expects(:save).returns(false)
        post :create, :course => { 'these' => 'params' }
      end

      it 'renders the new template' do
        response.should render_template('new')
      end

      it 'assigns @grade_types' do
        assigns(:grade_types).should == Course.grading_types_as_options
      end
    end
  end
end
