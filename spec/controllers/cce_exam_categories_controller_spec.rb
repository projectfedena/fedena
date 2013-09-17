require 'spec_helper'

describe CceExamCategoriesController do
  before do
    @user         = Factory.create(:admin_user)
    @cce_exam_cat = FactoryGirl.create(:cce_exam_category)
    sign_in(@user)
  end

  describe 'GET #index' do
    before do
      get :index
    end

    it 'renders the index template' do
      response.should render_template('cce_exam_categories/index')
    end

    it 'assigns all CceExamCategory as @cce_exam_cat' do
      assigns(:categories).should == [@cce_exam_cat]
    end
  end

  describe 'GET #new' do
    before do
      get :new
    end

    it 'renders the new template' do
      response.should render_template('cce_exam_categories/new')
    end

    it 'assigns new record to @category' do
      assigns(:category).should be_new_record
    end
  end

  describe 'POST #create' do
    context 'successful create' do
      before do
        CceExamCategory.any_instance.expects(:save).returns(true)
        post :create, :cce_exam_category => { :name => 'cce name', :desc => 'description' }
      end

      it 'assigns flash[:success]' do
        flash[:success].should == "Exam Category created successfully."
      end
    end

    context 'failed create' do
      before do
        CceExamCategory.any_instance.expects(:save).returns(false)
        post :create, :cce_exam_category => { :name => 'cce name', :desc => 'description' }
      end

      it 'assigns @error true' do
        assigns(:error).should be_true
      end
    end
  end

  describe 'GET #edit' do
    before do
      get :edit, :id => @cce_exam_cat.to_param
    end

    it 'renders the edit template' do
      response.should render_template('cce_exam_categories/edit')
    end

    it 'assigns @category' do
      assigns(:category).should == @cce_exam_cat
    end
  end

  describe 'PUT #update' do
    context 'successful update' do
      before do
        CceExamCategory.any_instance.expects(:save).returns(true)
        put :update, :id => @cce_exam_cat.to_param, :cce_exam_category => { :name => 'cce name', :desc => 'description' }
      end

      it 'assigns flash[:success]' do
        flash[:success].should == "Exam Category updated successfully."
      end
    end

    context 'failed update' do
      before do
        CceExamCategory.any_instance.expects(:save).returns(false)
        put :update, :id => @cce_exam_cat.to_param, :cce_exam_category => { :name => 'cce name', :desc => 'description' }
      end

      it 'assigns @error true' do
        assigns(:error).should be_true
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'successful destroy' do
      before do
        CceExamCategory.any_instance.expects(:destroy).returns(true)
        delete :destroy, :id => @cce_exam_cat.to_param
      end

      it 'assigns flash[:success]' do
        flash[:success].should == "Exam Category Deleted"
      end

      it 'redirects to index' do
        response.should redirect_to(cce_exam_categories_path)
      end
    end

    context 'failed destroy' do
      before do
        CceExamCategory.any_instance.expects(:destroy).returns(false)
        delete :destroy, :id => @cce_exam_cat.to_param
      end

      it 'assigns flash[:error]' do
        flash[:error].should == "Exam category cannot be deleted"
      end

      it 'redirects to the action index' do
        response.should redirect_to(cce_exam_categories_path)
      end
    end
  end
end