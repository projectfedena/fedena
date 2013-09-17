require 'spec_helper'

describe CceExamCategoriesController do
  before do
    @user         = Factory.create(:admin_user)
    @cce_exam_cat = mock_model(CceExamCategory)
    sign_in(@user)
  end

  describe 'GET #index' do
    before do
      CceExamCategory.stub(:all).and_return([@cce_exam_cat])
      get :index
    end

    it 'renders the index template' do
      response.should render_template('index')
    end

    it 'assigns all CceExamCategory as @cce_exam_cat' do
      assigns(:categories).should == [@cce_exam_cat]
    end
  end

  describe 'GET #new' do
    before do
      CceExamCategory.stub(:new).and_return(@cce_exam_cat)
      get :new
    end

    it 'renders the new template' do
      response.should render_template('new')
    end

    it 'assigns new record to @category' do
      assigns(:category).should == @cce_exam_cat
    end
  end

  describe 'POST #create' do
    before do
      CceExamCategory.stub(:new).with({ 'these' => 'params' }).and_return(@cce_exam_cat)
    end

    context 'successful create' do
      before do
        @cce_exam_cat.stub(:save).and_return(true)
        CceExamCategory.stub(:all).and_return([@cce_exam_cat])
        post :create, :cce_exam_category => { 'these' => 'params' }
      end

      it 'assigns flash[:notice]' do
        flash[:notice].should == "Exam Category created successfully."
      end

      it 'assigns new record with these params to @cce_exam_cat' do
        assigns(:categories).should == [@cce_exam_cat]
      end
    end

    context 'failed create' do
      before do
        @cce_exam_cat.stub(:save).and_return(false)
        post :create, :cce_exam_category => { 'these' => 'params' }
      end

      it 'assigns @error true' do
        assigns(:error).should be_true
      end
    end
  end

  describe 'GET #edit' do
    before do
      CceExamCategory.stub(:find).with('20').and_return(@cce_exam_cat)
      get :edit, :id => '20'
    end

    it 'renders the edit template' do
      response.should render_template('edit')
    end

    it 'assigns @category' do
      assigns(:category).should == @cce_exam_cat
    end
  end

  describe 'PUT #update' do
    before do
      CceExamCategory.stub(:find).with('20').and_return(@cce_exam_cat)
      @cce_exam_cat.should_receive(:name=).with('cce name')
      @cce_exam_cat.should_receive(:desc=).with('description')
    end

    context 'successful update' do
      before do
        @cce_exam_cat.stub(:save).and_return(true)
        CceExamCategory.stub(:all).and_return([@cce_exam_cat])
        put :update, :id => '20', :cce_exam_category => { :name => 'cce name', :desc => 'description' }
      end

      it 'assigns flash[:notice]' do
        flash[:notice].should == "Exam Category updated successfully."
      end

      it 'assigns @categories' do
        assigns(:categories).should == [@cce_exam_cat]
      end
    end

    context 'failed update' do
      before do
        @cce_exam_cat.stub(:save).and_return(false)
        put :update, :id => '20', :cce_exam_category => { :name => 'cce name', :desc => 'description' }
      end

      it 'assigns @error true' do
        assigns(:error).should be_true
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      CceExamCategory.stub(:find).with('20').and_return(@cce_exam_cat)
    end

    context 'successful destroy' do
      before do
        @cce_exam_cat.stub(:destroy).and_return(true)
        delete :destroy, :id => '20'
      end

      it 'assigns flash[:notice]' do
        flash[:notice].should == "Exam Category Deleted"
      end

      it 'redirects to the action index' do
        response.should redirect_to(:action => 'index')
      end
    end

    context 'failed destroy' do
      before do
        @cce_exam_cat.stub(:destroy).and_return(false)
        delete :destroy, :id => '20'
      end

      it 'assigns flash[:notice]' do
        flash[:notice].should == "Exam category cannot be deleted"
      end

      it 'redirects to the action index' do
        response.should redirect_to(:action => 'index')
      end
    end
  end
end